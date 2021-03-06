require 's3gb/base'

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
      ensure_jgit_config
      ensure_jgit_repo
    end

    def push
      cmd "cd #{cache_dir} && jgit push s3 refs/heads/master"
    end

    protected

    def jgit_s3
      File.expand_path('~/.jgit_s3')
    end

    def ensure_jgit_repo
      # this only works if a public repo already exists
      return if File.exist? "#{cache_dir}/.git"
      out = cmd "cd #{File.dirname(cache_dir)} && jgit clone -o s3 #{public_s3_url} #{File.basename cache_dir}"
      return if out.include?('COMPLETE')
      cmd "cd #{cache_dir} && git init ; git remote rm s3 ; git remote add s3 #{s3_url}"
    end

    def s3_url
      "amazon-s3://.jgit_s3@#{config['bucket']}/.git"
    end

    def public_s3_url
      "http://#{config['bucket']}.s3.amazonaws.com/.git"
    end

    def cmd x
      puts x
      `#{x}`
    end

    def ensure_jgit_config
      File.open(jgit_s3, 'w') do |f|
        f.write "accesskey: #{config['accessKeyId']}\nsecretkey: #{config['secretAccessKey']}\nacl: #{config['acl']||'private'}"
      end
    end
  end
end