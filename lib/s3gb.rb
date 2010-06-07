require 'yaml'

class S3gb
  def self.build
    strategy = case @config['strategy'].downcase
    when 'jgit', nil then JGit
    when 's3fs' then S3fs
    end

    strategy.new(YAML.load(File.read('config.yml')))
  end
end