require "pathname"
require "set"

module Mediabuckets
  module FileLister
    def self.file_list_rec(pathname)
      if pathname.directory? 
        self.all_files_loop_detec(pathname, Set.new)
      else
        []
      end
    end

    def self.all_files(pathname)
      pathname.children.select { |c| c.file? }
    end

    def self.all_dirs(pathname) 
      pathname.children.select { |c| c.directory? }
    end

    def self.all_files_loop_detec(pathname, visited) 
      # to avoid graph loops
      if visited.include? pathname.to_s
        return []
      else 
        visited.add pathname.to_s
      end
      files = all_files(pathname)
      # recur for every subdirectory
      all_dirs(pathname).each do |dir|
        files.concat(self.all_files_loop_detec(dir, visited))
      end
      files
    end
  end
end
