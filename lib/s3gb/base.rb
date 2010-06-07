require 'tempfile'

class S3gb
  class Base
    attr_accessor :config
    def initialize(config)
      @config = config
    end

    def backup
      prepare
      collect_files
      commit_changes
      push
    end

    def collect_files
      with_exclude_file do |excludes|
        config['sync'].each do |path|
          puts "now comes #{path}"
          full_path = "#{cache_dir}#{File.dirname(path)}"
          ensure_dir full_path
          `/usr/bin/rsync -avz --delete --exclude-from #{excludes} #{path} #{full_path}`
        end
      end
    end

    def self.commit_changes
      `cd #{cache_dir} && git init` unless File.exist?("#{cache_dir}/.git")
      `cd #{cache_dir} && git add . && git commit -m "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"`
    end

    protected

    def with_exclude_file
      Tempfile.open('foo') do |t|
        t.write config['exclude'] * "\n"
        t.close
        yield t.path
      end
    end

    def ensure_dir(dir)
      `mkdir -p #{dir}` unless File.exist?(dir)
    end

    def cache_dir
      @cache_dir ||= begin
        dir = File.expand_path('cache')
        ensure_dir dir
        dir
      end
    end
  end
end