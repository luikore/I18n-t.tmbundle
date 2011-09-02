require "i18n_project"

describe "I18nProject" do
  it "initialize when textmate env vars are defined" do
    ENV['TM_PROJECT_DIRECTORY'] = nil
    I18nProject.instance.should == nil
  end
  
  it "works" do
    ENV['TM_PROJECT_DIRECTORY'] = File.dirname(__FILE__) + '/fixtures/multi_keys'
    ENV['TM_FILEPATH'] = File.dirname(__FILE__) + '/fixtures/multi_keys/app/views/hello/world.slim'
    i = I18nProject.instance
    i.potential_i18n_keys('hello').sort.should == ['a.b.c', 'z']
    i.potential_i18n_keys('hello2').sort.should == []
    i.key_prefix.should == 'hello.world'
    i.no_translation('a.b.c').should == nil
    Fixnum.should === i.no_translation('z.b.c')
  end
end