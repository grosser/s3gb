require 'yaml'

class S3gb
  def self.build
    config = YAML.load(File.read(File.expand_path('~/.s3gb/config.yml')))

    strategy = case config['strategy'].downcase
    when 'jgit', nil then
      require 's3gb/jgit'
      JGit
    when 's3fs' then
      require 's3gb/s3fs'
      S3fs
    end

    strategy.new config
  end
end