require 'yaml'

class S3gb
  def self.build
    config = YAML.load(File.read(File.expand_path('~/.s3gb')))

    strategy = case config['strategy'].downcase
    when 'jgit', nil then JGit
    when 's3fs' then S3fs
    end

    strategy.new config
  end
end