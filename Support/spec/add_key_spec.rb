ENV['TM_SUPPORT_PATH'] = '/Applications/TextMate.app/Contents/SharedSupport/Support'
require "add_key"
require "tempfile"
require "yaml"

describe "add translation" do
  before do
    f = Tempfile.new 'yml'
    f.puts <<-YAML
en:
  a:
    a1: a2
  a:
    b1:
      b2: b3
    b:
      c1:
        c2: c3
      c: d
  e: f
    YAML
    f.close
    @file = f.path
  end

  it "inserts key if parent in keys" do
    add_translation @file, 'a.b.g', 'h'
    res = YAML.load_file(@file)['en']
    # puts File.read @file
    res['a']['b']['c'].should == 'd'
    res['a']['b']['g'].should == 'h'
  end

  it "appends key if parent not found" do
    add_translation @file, 'x.b.g', "line 1\nline2"
    res = YAML.load_file(@file)['en']
    # puts File.read @file
    res['e'].should == 'f'
    res['x']['b']['g'].should == "line 1\nline2"
  end

  it "flattens i18n keys" do
    ENV['TM_PROJECT_DIRECTORY'] = File.dirname(__FILE__) + '/fixtures/multi_keys'
    load_i18n
    potential_i18n_keys('hello').sort.should == ['a.b.c', 'z']
    potential_i18n_keys('hello2').sort.should == []
  end
end
