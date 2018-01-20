require "mimemagic"
require "mimemagic/overlay"

module Mediabuckets
  module Buckets
    FSinfo = Mediabuckets::FSinfo

    def self.gen_buckets(dirname)
      filenames = FSinfo.file_list_rec(dirname)
      self.gen_bucketToFileInfos(self.gen_hashToPathnames(filenames))
    end

    def self.gen_hashToPathnames(pathnames)
      hashToPathnames = Hash.new
      pathnames.each do |pathname|
        filehash = FSinfo.get_filehash(pathname)
        if hashToPathnames.include?(filehash)
          # add to the list
          hashToPathnames[filehash].push(pathname)
        else
          hashToPathnames[filehash] = [pathname]
        end
      end
      hashToPathnames
    end

    def self.gen_bucketToFileInfos(hashToPathnames) 
      bucketToFileInfos = Hash.new
      hashToPathnames.each do |filehash, pathnames| 
        bucket = self.get_mediabucket(pathnames.first)
        if bucketToFileInfos.include? bucket
          bucketToFileInfos[bucket].push([filehash, pathnames])
        else
          bucketToFileInfos[bucket] = [[filehash, pathnames]]
        end
      end 
      bucketToFileInfos
    end

    def self.get_mediabucket(pathname)
      mm = MimeMagic.by_magic(File.open(pathname))
      if mm == nil
        "unknown"
      elsif mm.mediatype == "application"
        "application"
      elsif mm.video?
        "video"
      elsif mm.image?
        "image"
      elsif mm.audio?
        "audio"
      elsif mm.text?
        "text"
      else
        "other"
      end
    end
  end
end
