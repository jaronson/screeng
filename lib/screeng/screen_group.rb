class Screeng::ScreenGroup
  attr_reader :source_file
  attr_reader :options

  attr_accessor :json
  attr_accessor :session_name
  attr_accessor :primary_pos
  attr_accessor :shell_commands
  attr_accessor :screen_commands

  def self.cache_directory(root)
    "#{root}/cached"
  end

  def self.digest(d)
    Digest::MD5.hexdigest(d)
  end

  def initialize(filename, options)
    @source_file = filename
    @options     = options

    @session_name     = 'screeng'
    @primary_pos      = 0
    @shell_commands   = []
    @screen_commands  = []
  end

  def screen_config
    @screen_config ||= File.join(options[:screeng], session_name.to_s)
  end

  def cache_directory
    self.class.cache_directory(options[:screeng])
  end

  def cache_file
    @cache_file ||= File.join(cache_directory, "#{self.class.digest(source_file)}.cache")
  end

  def checksum
    @checksum ||= self.class.digest(@json)
  end

  def cached_matches?
    if File.exists?(cache_file)
      cached_checksum = File.open(cache_file, &:readline).scan(/(checksum:\s+)(.*)$/).flatten.last
      return cached_checksum == checksum
    end

    false
  end
end
