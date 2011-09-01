# encoding: UTF-8

require "rubygems" if RUBY_VERSION < '1.9'
require "yaml"
YAML::ENGINE.yamler = 'syck' if RUBY_VERSION >= '1.9'
require "i18n"
require File.expand_path(ENV['TM_SUPPORT_PATH']) + '/lib/ui'

class String
  # different from activesupport, also tr ' ' to '_'
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("- ", "_").
      downcase
  end
end

def key_prefix
  project_directory = File.expand_path ENV['TM_PROJECT_DIRECTORY']
  file = ENV['TM_FILEPATH']
  key_name = File.expand_path(file).sub("#{project_directory}/app/views", '')
  key_name.sub!(/(\.slim|\.haml|\.html\.erb)$/, '')
  key_name.gsub('/', '.').sub(/^\./, '').sub(/\.$/, '')
end

def en_path
  project_directory = File.expand_path ENV['TM_PROJECT_DIRECTORY']
  %w[en.yml en.yaml].each do |l|
    file = "#{project_directory}/config/locales/#{l}"
    return file if File.exist?(file)
  end
  nil
end

def load_i18n
  project_directory = File.expand_path ENV['TM_PROJECT_DIRECTORY']
  I18n.load_path = Dir.glob("#{project_directory}/config/locales/*.{yml,yaml}")
  I18n.reload!
  I18n.locale = 'en'
end

def keys_containing value, from, result, prefix
  if value == from
    result << prefix
  elsif from.is_a?(Hash)
    prefix += '.' if !prefix.empty?
    from.each do |k, v|
      keys_containing value, v, result, "#{prefix}#{k}"
    end
  else
    # what ?
  end
end

def potential_i18n_keys v
  I18n.t 'x' # make it load
  data = I18n.backend.instance_variable_get(:@translations)
  return [] if !data or !data[:en]
  x = []
  keys_containing v, data[:en], x, ''
  x
end

# seek for best match pos
def seek_pos lines, series
  i, j = 0, 0
  best_match = [nil, nil]
  while line = lines[i]
    i += 1
    if line !~ /^\s*$/
      indent, _, _, pattern = series[j]
      if line =~ pattern
        j += 1
        best_match = [i, j] if !best_match[1] or best_match[1] < j
      else
        leading = line[/^\s*/].size
        # when 0?
        if leading > 0 and leading < indent.size
          i -= 1
          j = leading / 2 - 1
        end
      end
    end
  end
  best_match
end

def add_translation yml_path, k, v
  # todo quote key if ':' in series
  series = k.split('.').each_with_index.to_a.map do |pair|
    part, i = pair
    indent = ' ' * (i + 1) * 2
    pattern = /^#{Regexp.escape indent}
      (?:(['"]?)#{Regexp.escape part}\1|\:#{Regexp.escape part})
      \:[\ \n]
    /x
    [indent, part, i, pattern]
  end
  lines = File.readlines(yml_path).to_a

  # insert
  i, id = seek_pos lines, series
  new_key = []
  series[(id || 0)..-1].each do |e|
    new_key << (e[0] + e[1] + ':')
  end
  v = v.inspect if v.index("\n")
  new_key.last << ' ' << v
  new_key.map! {|l| l + "\n" }
  new_key = new_key.join
  if i
    lines.insert i, new_key
  else
    lines << new_key
  end

  # write
  lines = lines.join
  File.open yml_path, 'w' do |f|
    f << lines
  end
end

def add_key input, en_path
  v = input.strip
  if v =~ /^(["']).+\1$/
    v = v[1...-1]
    quote = true
  end

  if ARGV[1] == 'select' # select from translations
    items = potential_i18n_keys v
    if !items.empty?
      k = TextMate::UI.request_item \
        :title => "Select Translation Key",
        :prompt => 'Select Translation Key',
        :items => items
    end
    return input if !k
  else                   # new translation if needed
    v.gsub! '.', ''
    k = v[0..0].downcase + v[1..-1].underscore
    full_k = "#{key_prefix}.#{k}"
    res = I18n.t full_k
    if res =~ /translation\ missing/
      new_k = TextMate::UI.request_string :default => full_k,
        :title => "New Translation Key"
      return input if new_k.nil? or new_k.empty?
      if new_k != full_k
        full_k = new_k
        k = new_k
      else
        k = '.' + k
      end
      add_translation en_path, full_k, v
    else
      k = '.' + k
    end
  end

  # snippet
  if quote or ARGV[0] == 'rb'
    %Q|t(#{k.inspect})|
  else
    case ARGV[0]
    when 'slim'; quote ? %Q|t(#{k.inspect})| : %Q|= t #{k.inspect}|
    when 'haml'; quote ? %Q|t(#{k.inspect})| : %Q|= t #{k.inspect}|
    else %Q|<%= t #{k.inspect} %>|
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if ENV['TM_PROJECT_DIRECTORY'] and (en_path = en_path())
    load_i18n
    print(add_key $stdin.read, en_path)
  else
    print $stdin.read
  end
end