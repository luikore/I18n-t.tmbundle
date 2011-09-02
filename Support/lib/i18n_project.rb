# encoding: UTF-8

require "rubygems" if RUBY_VERSION < '1.9'
require "yaml"
YAML::ENGINE.yamler = 'syck' if RUBY_VERSION >= '1.9'
require "i18n"

class String
  # different from activesupport, also tr ' ' to '_'
  def underscore
    gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("- ", "_").
      downcase
  end

  def unquote
    v = strip
    if v =~ /^(["']).+\1$/
      v = v[1...-1]
      quote = true
    end
    [v, quote]
  end
end

class I18nProject
  def self.instance
    I18nProject.new rescue nil
  end

  attr_reader :en_yml_path

  def initialize
    @project_directory = File.expand_path ENV['TM_PROJECT_DIRECTORY']
    @file = File.expand_path ENV['TM_FILEPATH']
    en_yml_potentials = %w[en.yml en.yaml].map do |l|
      "#@project_directory/config/locales/#{l}"
    end
    @en_yml_path = en_yml_potentials.find do |f|
      File.exist? f
    end
    if !@en_yml_path
      # TODO show tip
      raise 'not found'
    end

    I18n.load_path = Dir.glob("#@project_directory/config/locales/*.{yml,yaml}")
    I18n.reload!
    I18n.locale = 'en'
    I18n.t 'x' # make it load
  end

  # by view template name
  def key_prefix
    key_name = @file.sub("#@project_directory/app/views", '')
    key_name.sub!(/(\.slim|\.haml|\.html\.erb)$/, '')
    key_name.gsub('/', '.').sub(/^\./, '').sub(/\.$/, '')
  end

  def no_translation key
    I18n.t(key) =~ /translation\ missing/
  end

  def potential_i18n_keys search_value
    data = I18n.backend.instance_variable_get(:@translations)
    return [] if !data or !data[:en]
    @keys = []
    @search_value = search_value
    search_keys data[:en], ''
    @keys
  end

  private

  # insert into `@keys` the existed key in `from` that translates into `@search_value`
  def search_keys from, prefix
    if @search_value == from
      @keys << prefix
    elsif from.is_a?(Hash)
      prefix += '.' if !prefix.empty?
      from.each do |k, sub_hash_or_string|
        search_keys sub_hash_or_string, "#{prefix}#{k}"
      end
    else
      # what ?
    end
  end
end
