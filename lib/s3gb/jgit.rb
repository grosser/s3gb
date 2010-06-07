class S3gb
  class JGit < S3gb::Base
    def install
      require 'open-uri'
      page = open('http://www.eclipse.org/jgit/download/').read
      url = page.match(/"(.*?org.eclipse.jgit.*?.sh)"/)[1]
      file = File.basename(url)
      to = '/usr/bin/jgit'
      `sudo rm #{to}`
      `cd /tmp && rm #{file} ; wget #{url} && sudo mv #{file} #{to} && sudo chmod 755 #{to}`
    end

    def prepare
      ensure_git_repo
      ensure_jgit_config
      ensure_jgit_remote
      `cd #{cache_dir} && jgit pull`
    end

    protected

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
  end
end