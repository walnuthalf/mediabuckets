require "mediabuckets/version"
require "mediabuckets/filelister"
require "mediabuckets/trimmer"
require "mediabuckets/action"

module Mediabuckets
  def self.arrange(source, dest, command)
    sourcename = Pathname.new source
    destname = Pathname.new dest
    if not destname.exist?
      FileUtils.mkdir destname
    end
    if not destname.empty?
      raise "destination directory is not empty"
    end
    logpathname = destname.join "__log__"
    logger = Logger.new(logpathname)
    Mediabuckets::Action.arrange(sourcename, destname, command, logger)
    :ok
  end
end
