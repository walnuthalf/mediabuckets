require "set"
require "logger"
require "json"

module Mediabuckets
  module Action
    MAX_FILENAME_LENGTH = 255

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
      self.arrange_p(sourcename, destname, command, logger)
      :ok
    end

    def self.gen_unique_basename(sourcename, hash, maxFilenameLength=MAX_FILENAME_LENGTH) 
      base = sourcename.basename.to_s
      newbase = if base.length + hash.length <= (maxFilenameLength - 1)
        hash + "_" + base
      else
        lastPos = maxFilenameLength - hash.length - 2 
         hash + "_" + base[0 .. lastPos]
      end
      Pathname.new newbase
    end

    def self.run_command(command, source, dest)
      case command
      when "link" then FileUtils.ln(source, dest)
      when "move" then FileUtils.mv(source, dest)
      when "copy" then FileUtils.cp(source, dest)
      else :unknown
      end
    end

    def self.select_best_pathname(pathnames)
      pathnames.reduce do |longest, pathname|
        filename = pathname.basename.to_s
        longestFilename = longest.basename.to_s
        if  filename.length > longestFilename.length 
          pathname
        else
          longest
        end
      end
    end

    def self.arrange_p(sourcename, destname, command, logger)
      filenames = Mediabuckets::FileLister.file_list_rec(sourcename)
      bucketToFileInfos = Mediabuckets::Trimmer.gen_buckets(filenames)

      bucketToFileInfos.each do |bucket, fileInfos|
        bucketPathname = destname.join bucket

        FileUtils.mkdir bucketPathname
        payload =  {operation: "bucket created", 
                    bucket: bucket}
        logger.info(JSON.generate(payload)) 
        
        # set of filenames to avoid name collision
        basenames = Set.new

        fileInfos.each do |fileInfo|
          filehash, pathnames = fileInfo
          bestPathname = self.select_best_pathname(pathnames)
          # set only works if string is given
          if basenames.include? bestPathname.basename.to_s
            destBasename = self.gen_unique_basename(bestPathname, filehash)
          else
            destBasename = bestPathname.basename
          end
          basenames.add destBasename.to_s
          self.run_command(command, bestPathname.to_s, bucketPathname.join(destBasename))

          payload = {operation: "command performed", 
                     command: command, 
                     source: sourcename.to_s, 
                     dest: destname.to_s}
          logger.info(JSON.generate(payload)) 
        end
      end
    end
  end
end
