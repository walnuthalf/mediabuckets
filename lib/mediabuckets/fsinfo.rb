require "pathname"
require "set"
require "digest"

module Mediabuckets
  module FSinfo
    def self.get_filehash(pathname)
      Digest::SHA256.file(pathname).hexdigest
    end 

    def self.all_files(pathname)
      pathname.children.select { |c| c.file? }
    end

    def self.all_dirs(pathname) 
      pathname.children.select { |c| c.directory? }
    end

    def self.get_hash_and_name(pathname)
      [pathname.basename.to_s, self.get_filehash(pathname)]
    end

    def self.file_list_rec(pathname, visited=Set.new)
      # to avoid graph loops
      if visited.include? pathname.to_s
        return []
      else 
        visited.add pathname.to_s
      end
      files = self.all_files(pathname)
      # recur for every subdirectory
      self.all_dirs(pathname).each do |dir|
        files.concat(self.file_list_rec(dir, visited))
      end
      files
    end

    def self.gen_dir_tree(dirname, visited=Set.new) 
      dirTree = Hash.new
      dirTree["dirname"] = dirname.basename.to_s
      dirTree["files"] = all_files(dirname).map do |filename|
        [filename.basename.to_s, get_filehash(filename)]
      end
      # recur for every subdirectory
      dirTree["dirs"] = []
      all_dirs(dirname).each do |subdir|
        if not visited.include?(subdir.to_s)
          dirTree["dirs"].push(gen_dir_tree(subdir, visited))
          visited.add subdir.to_s
        end
      end
      dirTree
    end

    def self.apply_till_false(funcArgs)
      funcArgs.each do |fa|
        func, args = fa
        if not func.call(*args)
          # not all funcs evaled to true
          return false
        end
      end
      # all funcs evaled to true
      true
    end

    def self.compare_dirs(dir1, dir2)
      compare_files = lambda do |file1, file2|
        basename1, hash1 = file1
        basename2, hash2 = file2
        (basename1 == basename2) and (hash1 == hash2)
      end
      same_filelist_length = lambda do |dir1, dir2|
        dir1["files"].length == dir2["files"].length
      end
      same_subdirs_length = lambda do |dir1, dir2|
        dir1["dirs"].length == dir2["dirs"].length
      end
      same_files = lambda do |dir1, dir2|
        # handle this edge case, or reduce will return nil
        if dir1["files"].empty?
          return true
        end
        comparedFiles = dir1["files"].zip(dir2["files"]).map do |twoFiles|
          file1, file2 = twoFiles 
          compare_files.call(file1, file2)
        end
        comparedFiles.reduce do |acc, el|
          acc and el
        end
      end
      same_subdirs = lambda do |dir1, dir2|
        # handle this edge case, or reduce will return nil
        if dir1["dirs"].empty?
          return true
        end
        dir1["dirs"].zip(dir2["dirs"]).map do |twoDirs|
          subdir1, subdir2 = twoDirs 
          self.compare_dirs(subdir1, subdir2)
        end
      end
      dirs = [dir1, dir2]
      funcArgs = [
        [same_filelist_length, dirs],
        [same_files, dirs],
        [same_subdirs_length, dirs],
        [same_subdirs, dirs]
      ]
      self.apply_till_false(funcArgs)
    end
  end
end
