require "digest"
require "mimemagic"
require "mimemagic/overlay"

module Mediabuckets
  module Trimmer 
    def self.get_filehash(pathname)
      Digest::SHA256.file(pathname).hexdigest
    end 

    def self.gen_buckets(pathnames)
      self.gen_bucketToFileInfos(self.gen_hashToPathnames(pathnames))
    end

    def self.gen_hashToPathnames(pathnames)
      hashToPathnames = Hash.new
      pathnames.each do |pathname|
        filehash = get_filehash(pathname)
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
