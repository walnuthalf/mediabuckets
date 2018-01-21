require "set"
require "pry"

RSpec.describe Mediabuckets do
  TEST_AREA = Pathname.new("./test_area")
  DEST = Pathname.new("./test_area/buckets")
  SOURCE = Pathname.new("./test_area/samples")
  SAMPLES = Pathname.new("./samples")
  LOG = Pathname.new("./test_area/buckets/__log__")
  def setup_test_area
    if not TEST_AREA.exist?
      FileUtils.mkdir TEST_AREA
    elsif not TEST_AREA.empty?
      # remove all directory contents
      FileUtils.rm_rf(Dir.glob(TEST_AREA.join("*")))
    end
    FileUtils.copy_entry(SAMPLES, SOURCE) 
  end

  def run_arrange(command)
    Mediabuckets.arrange(SOURCE, DEST, command)
  end
  
  def contents_match?(sourcename, destname)
    def gen_contents_set(dirname, nolog=false)
     filenames = Mediabuckets::FSinfo.file_list_rec(dirname)
     if nolog
       filenames = filenames.select do |f|
         f != LOG
       end
     end
     Set.new(filenames.map do |f|
       Mediabuckets::FSinfo.get_filehash(f)
     end)  
    end
    s1 = gen_contents_set sourcename
    s2 = gen_contents_set(destname, true)
    s1 == s2
  end

  def all_files_symlinks?(dirname)
    filenames = Mediabuckets::FSinfo.file_list_rec(dirname)
    nonsymlinks = filenames.select do |f|
      (f != LOG) or not (File.symlink? f) 
    end
    nonsymlinks.empty?
  end

  def check_media_types
    def in_bucket?(bucket, name)
      DEST.join(bucket).join(name).exist?
    end
    data = [["audio", "audio1.mp3"],
      ["audio", "audio2.mp3"],
      ["video", "video1.mp4"],
      ["application", "document1.pdf"],
      ["image", "image1.jpg"],
      ["image", "image2.jpg"],
      ["image", "image3.jpg"],
      ["image", "image1.png"],
      ["image", "image2.png"]]
    data.each do |d|
      if not in_bucket?(*d)
        return false
      end
    end
    true
  end

  it "has a version number" do
    expect(Mediabuckets::VERSION).not_to be nil
  end

  describe "command tests" do 
    before(:each) do
      # make test_area
      setup_test_area 
    end
    after(:each) do
      # have all files been processed?
      expect(contents_match?(SAMPLES, DEST)).to be true
      # files in the right buckets?
      expect(check_media_types).to be true
    end

    it "tests .arrange with link" do
      run_arrange("link")
      # is the source directory intact?
      expect(Mediabuckets::FSinfo.compare_dirs(SAMPLES, SOURCE)).to be true
    end

    it "tests .arrange with copy" do
      run_arrange("copy")
      # is the source directory intact?
      expect(Mediabuckets::FSinfo.compare_dirs(SAMPLES, SOURCE)).to be true
    end

    it "tests .arrange with move" do
      run_arrange("move")
      # is the source directory empty of files?
      filesInSource = Mediabuckets::FSinfo.file_list_rec(SOURCE)
      expect(filesInSource).to match_array([])
    end
  end
end
