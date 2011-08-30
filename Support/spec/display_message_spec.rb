require "display_message"

describe "display message" do
  before do
    @project = File.expand_path("fixtures/one_locale", File.dirname(__FILE__))
  end

  it "works for double quotes" do
    line = %Q{  msg = I18n.t("my.project.message") }
    display(line).should == "en: This is my project's message"
  end

  it "works for single quotes" do
    line = %Q{  msg = I18n.t('my.project.message') }
    display(line).should == "en: This is my project's message"
  end

  it "works for double quotes for multi locale" do
    line = %Q{  msg = I18n.t("my.project.message") }
    project = File.expand_path("fixtures/multi_locale", File.dirname(__FILE__))
    display(line, project).should == "en: This is my project's message\nfr: Bonjour!"
  end

  def display line, project=@project
    display_message line, 18, project
  end
end