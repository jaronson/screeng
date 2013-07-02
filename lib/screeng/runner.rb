class Screeng::Runner
  def self.banner
    "Use me this way:\n  screeng-runner <filename> [options]\n\nwith options:"
  end

  def self.go(filename, opts = {})
    new(filename, opts).run
  end

  attr_reader :filename
  attr_reader :options

  attr_reader :parser
  attr_reader :writer

  attr_reader :screen_group
  attr_reader :session_name

  def initialize(filename, opts = {})
    @filename = filename.chomp.strip if filename
    @options  = opts

    if !filename || filename == ''
      exit_badly
    elsif !File.exists?(filename)
      puts "I couldn't find #{filename}. You sure it exists?"
      exit_badly
    end
  end

  def run
    begin
      if parse_screen_group
        write_screen_group
      end
    rescue Screeng::Error => e
      puts e.message
      exit_badly
    end
  end

  def inform(msg)
    puts msg
  end

  protected
  def parse_screen_group
    @parser = Screeng::Parser.new(self)
    @screen_group = parser.parse
  end

  def write_screen_group
    @writer = Screeng::Writer.new(self)
    writer.write
  end

  private
  def exit_badly
    raise Trollop::HelpNeeded
    exit(1)
  end

  def exit_well
    exit(0)
  end
end
