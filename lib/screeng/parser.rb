class Screeng::Parser
  attr_reader :runner
  attr_reader :filename
  attr_reader :options

  attr_reader :screen_group
  attr_reader :group

  def initialize(runner)
    @runner   = runner
    @filename = runner.filename
    @options  = runner.options
  end

  def parse
    @screen_group     = Screeng::ScreenGroup.new(filename, options)
    screen_group.json = File.read(filename)

    if screen_group.cached_matches?
      runner.inform('Identical, skipping')
      return false
    end

    begin
      @group = JSON.parse(screen_group.json, :symbolize_names => true)
    rescue JSON::ParserError => e
      raise Screeng::Error.new("Looks like you've got some bad JSON:\n  #{e.message}")
    end

    setup
    finish
  end

  private
  # I'll default to first session loaded
  # unless options[:group] is specified
  def setup
    group.each do |name, windows|
      next if options[:group] && name != options[:group]

      setup_session(name)

      windows.each_with_index do |win, i|
        setup_window(win, i)
      end

      add_command(:screen, 'select %s', screen_group.primary_pos)

      break
    end
  end

  def setup_session(name)
    screen_group.session_name = name
    add_command(:shell, "screen -S %s -c %s", screen_group.session_name, screen_group.screen_config)
  end

  def setup_window(win, pos)
    if title = get_window_opt(win, :title)
      if execute = get_window_opt(win, :exec)
        add_command(:screen, "screen -t %s %s %s", title, pos, execute)
      else
        add_command(:screen, "screen -t %s %s", title, pos)

        if on_startup = get_window_opt(win, :onStartup)
          on_startup.respond_to?(:each) ? on_startup.each{|c| add_stuff_command(c) } : add_stuff_command(c)
        end
      end

      if directory = get_window_opt(win, :directory)
        add_command(:screen, "chdir %s", directory)
      end

      if primary = get_window_opt(win, :primary)
        @primary_pos = pos
      end
    elsif win.is_a?(String)
      add_command(:screen, "screen -t %s %s", win, pos)
    end
  end

  def get_window_opt(win, key)
    win.respond_to?(:keys) ? win[key] : nil
  end

  def add_stuff_command(cmd)
    add_command(:screen, 'stuff "%s%s"', cmd, '^M')
  end

  def finish
    debug
    screen_group
  end

  def debug
    debug_commands = lambda{|cmds| cmds.map{|c| "  #{c}" }.join("\n")    }

    puts [
      screen_group.session_name,
      'shell commands:',
      debug_commands.call(screen_group.shell_commands),
      'screen commands:',
      debug_commands.call(screen_group.screen_commands)
    ].join("\n")
  end

  def add_command(*args)
    screen_group.send(:"#{args.shift}_commands") << args.shift % args
  end
end
