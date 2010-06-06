require 'yaml'
require 'tempfile'

module S3gb
  def self.config
    @@config ||= YAML.load(File.read('config.yml'))
  end

  def self.mount
    `mkdir #{mount_dir}` unless File.exist?(mount_dir)
    `/usr/bin/s3fs #{config['bucket']} -o accessKeyId=#{config['accessKeyId']} -o secretAccessKey=#{config['secretAccessKey']} #{mount_dir}`
  end

  def self.unmount
    `/bin/umount #{mount_dir}`
  end

  def self.mount_dir
    File.expand_path('fs')
  end

  def self.cache_dir
    File.expand_path('cache')
  end

  def self.install_s3fs
    require 'open-uri'
    url = "http://code.google.com/p/s3fs"
    page = open(url).read
    path = page.match(%r{href="(.*?-source\.tar\.gz)"})[1]
    url = "http://s3fs.googlecode.com/files/#{path.split('=').last}"
    puts "installing from #{url}"
    `cd /tmp && wget #{url} && tar -xzf s3fs* && cd s3fs && make && sudo make install`
  end

  def self.backup
    ensure_dir cache_dir
    mount
    collect_files
    create_commit
    sync_files
    unmount
  end

  def self.ensure_dir(dir)
    `mkdir -p #{dir}` unless File.exist?(dir)
  end

  def self.collect_files
    ensure_dir cache_dir
    with_exclude_file do |excludes|
      config['sync'].each do |path|
        puts "now comes #{path}"
        full_path = "#{cache_dir}#{File.dirname(path)}"
        ensure_dir full_path
        `/usr/bin/rsync -avz --delete --exclude-from #{excludes} #{path} #{full_path}`
      end
    end
  end

  def self.create_commit
    ensure_dir cache_dir
    unless File.exist?("#{cache_dir}/.git")
      `cd #{cache_dir} && git init`
    end
    `cd #{cache_dir} && git add . && git commit -m "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"`
  end

  def self.sync_files
    `/usr/bin/rsync -avz --delete #{cache_dir}/ #{mount_dir}`
  end

  private

  def self.with_exclude_file
    Tempfile.open('foo') do |t|
      t.write config['exclude'] * "\n"
      t.close
      yield t.path
    end
  end
end