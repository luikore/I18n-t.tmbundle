# encoding: UTF-8

require File.expand_path(ENV['TM_SUPPORT_PATH']) + '/lib/ui'
require File.expand_path('i18n_project', File.dirname(__FILE__))

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

def insert_translation yml_path, k, v
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

def add_key i18n_prj, input
  v, quote = input.unquote

  if ARGV[1] == 'select' # select from translations
    items = i18n_prj.potential_i18n_keys v
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
    full_k = "#{i18n_prj.key_prefix}.#{k}"
    if i18n_prj.no_translation(full_k)
      new_k = TextMate::UI.request_string \
        :default => full_k,
        :title => "New Translation Key"
      return input if new_k.nil? or new_k.empty?
      if new_k != full_k
        full_k = new_k
        k = new_k
      else
        k = '.' + k
      end
      insert_translation i18n_prj.en_yml_path, full_k, v
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
  if i = I18nProject.instance
    print(add_key i, $stdin.read)
  else
    print $stdin.read
  end
end