class S3gb
  class S3fs
    def prepare
      `mkdir #{mount_dir}` unless File.exist?(mount_dir)
      `/usr/bin/s3fs #{config['bucket']} -o accessKeyId=#{config['accessKeyId']} -o secretAccessKey=#{config['secretAccessKey']} #{mount_dir}`
    end

    def install
      `sudo apt-get install build-essential libcurl4-openssl-dev libxml2-dev libfuse-dev`
      require 'open-uri'
      url = "http://code.google.com/p/s3fs"
      page = open(url).read
      path = page.match(%r{href="(.*?-source\.tar\.gz)"})[1]
      url = "http://s3fs.googlecode.com/files/#{path.split('=').last}"
      puts "installing from #{url}"
      `cd /tmp && wget #{url} && tar -xzf s3fs* && cd s3fs && make && sudo make install`
    end

    def push
      Dir.glob("#{cache_dir}/*", File::FNM_DOTMATCH).each do |sub_path|
        sub_path = File.basename(sub_path)
        next if ['.','..'].include?(sub_path)
        puts "syncing #{sub_path}"
        `/usr/bin/rsync -avz --delete #{cache_dir}/#{sub_path} #{mount_dir}`
      end
    end

    private

    def mount_dir
      File.expand_path('fs')
    end
  end
end