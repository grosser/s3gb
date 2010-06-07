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

  def self.install_jgit
    require 'open-uri'
    page = open('http://www.eclipse.org/jgit/download/').read
    url = page.match(/"(.*?org.eclipse.jgit.*?.sh)"/)[1]
    file = File.basename(url)
    to = '/usr/bin/jgit'
    `rm #{file}*`
    `sudo rm #{to}`
    `cd /tmp && wget #{url} && sudo mv #{file} #{to} && sudo chmod 755 #{to}`
  end

  def self.backup
    ensure_dir cache_dir
    case config['strategy']
    when 'rsync', nil then
      mount
      collect_files
      create_commit
      sync_files
    when 'jgit' then
      pull  
      collect_files
      create_commit
      push
    else
      raise "unknown strategy #{config['strategy']}"
    end
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

  def self.pull
    init_cache_dir
    ensure_jgit_config
    ensure_jgit_remote
    `cd #{cache_dir} && jgit pull`
  end

  def self.create_commit
    init_cache_dir
    `cd #{cache_dir} && git add . && git commit -m "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"`
  end

  def self.init_cache_dir
    ensure_dir cache_dir
    unless File.exist?("#{cache_dir}/.git")
      `cd #{cache_dir} && git init`
    end
  end

  def self.sync_files
    Dir.glob("#{cache_dir}/*", File::FNM_DOTMATCH).each do |sub_path|
      sub_path = File.basename(sub_path)
      next if ['.','..'].include?(sub_path)
      puts "syncing #{sub_path}"
      `/usr/bin/rsync -avz --delete #{cache_dir}/#{sub_path} #{mount_dir}`
    end
  end

  private

  def jgit_s3
    File.expand_path('~/.jgit_s3')
  end

  def ensure_jgit_remote
    `cd #{cache_dir} && git remote add s3 amazon-s3://.jgit_s3@#{config['bucket']}/#{config['bucket']}.git`
  end

  def ensure_jgit_config
    return if File.exist?(jgit_s3)
    File.open(jgit_s3, 'w') do |f|
      f.write "accesskey: #{config['accessKeyId']}\nsecretkey: #{config['secretAccessKey']}\nacl: private"
    end
  end

  def self.with_exclude_file
    Tempfile.open('foo') do |t|
      t.write config['exclude'] * "\n"
      t.close
      yield t.path
    end
  end
end