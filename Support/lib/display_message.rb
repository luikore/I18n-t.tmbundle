require "rubygems" if RUBY_VERSION < '1.9'
require "yaml"
YAML::ENGINE.yamler = 'syck'
require 'i18n'

def display_message current_line, column, project_directory, file=nil
  column = column.to_i
  column = current_line[0...column].rindex(/["']/) || column
  if current_line[column..-1] =~ /(["'])(.+?)\1/
    i18n_key = $2
    # fix keys start with '.'
    if file and i18n_key.start_with?(".")
      prefix = File.expand_path(file).sub(File.expand_path("#{project_directory}/app/views"), '')
      i18n_key = prefix.sub(/\..+$/, '').sub(/^\//, '').gsub("/", '.') + i18n_key
    end

    locale_files = Dir[File.join(project_directory, '**', 'locales', '*.yml')]
    return "Error: config/locales empty" if locale_files.empty?

    original_load_path, original_locale = I18n.load_path, I18n.locale
    messages = locale_files.inject({}) do |mem, locale_file|
      I18n.load_path = [locale_file]
      I18n.reload!
      I18n.locale = I18n.backend.available_locales.first
      mem[I18n.locale] = nil if mem[I18n.locale] =~ /translation missing/
      mem[I18n.locale] ||= I18n.t(i18n_key) if I18n.t(i18n_key)
      mem
    end
    I18n.locale, I18n.load_path = original_locale, original_load_path

    locale_messages = []
    messages.each do |pair|
      locale, string = pair
      string = '' if string =~ /translation missing/ # don't mess up my eyes !
      locale_messages << "#{locale}: #{string}"
    end
    locale_messages.sort.join("\n")
  else
    "Error: can not find translation key"
  end
end

if __FILE__ == $PROGRAM_NAME
  msg = display_message \
    ENV['TM_CURRENT_LINE'],
    ENV['TM_LINE_INDEX'],
    ENV['TM_PROJECT_DIRECTORY'],
    ENV['TM_FILEPATH']
  print msg
end
