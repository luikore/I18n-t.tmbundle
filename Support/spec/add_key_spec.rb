ENV['TM_SUPPORT_PATH'] = '/Applications/TextMate.app/Contents/SharedSupport/Support'
require "add_key"
require "tempfile"

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
    insert_translation @file, 'a.b.g', 'h'
    res = YAML.load_file(@file)['en']
    # puts File.read @file
    res['a']['b']['c'].should == 'd'
    res['a']['b']['g'].should == 'h'
  end

  it "appends key if parent not found" do
    insert_translation @file, 'x.b.g', "line 1\nline2"
    res = YAML.load_file(@file)['en']
    # puts File.read @file
    res['e'].should == 'f'
    res['x']['b']['g'].should == "line 1\nline2"
  end

  it "seek pos" do
    lines = File.readlines(@file).to_a
    (seek_pos lines, 'e'.to_series).should == [11, 1]
    (seek_pos lines, 'a.b1'.to_series).should == [6, 2]
    (seek_pos lines, 'a.a1.a3'.to_series).should == [3, 2]
  end
end
