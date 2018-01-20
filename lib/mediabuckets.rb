require "mediabuckets/version"
require "mediabuckets/fsinfo"
require "mediabuckets/buckets"
require "mediabuckets/action"

module Mediabuckets
  # Sorts all files from source directory by media type, 
  # filters identical files,
  # links, saves, or moves files to the destination directory.
  # Params:
  # +source+:: source directory. String. 
  # +dest+:: destination directory. String. 
  # +command+:: which UNIX command to use. "link", "copy", "move"  
  def self.arrange(source, dest, command)
    sourcename = Pathname.new source
    destname = Pathname.new dest
    if not destname.exist?
      FileUtils.mkdir destname
    end
    if not destname.empty?
      raise "destination directory #{dest} is not empty"
    end
    logpathname = destname.join "__log__"
    logger = Logger.new(logpathname)
    Mediabuckets::Action.arrange(sourcename, destname, command, logger)
    :ok
  end
end
