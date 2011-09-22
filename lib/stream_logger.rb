require "stream_logger/io_proxy"
require "stream_logger/version"

class StreamLogger
  LEVELS = [:fatal, :error, :warn, :info, :debug]
  DEFAULT_LEVEL = :info
  DEFAULT_FORMAT = Proc.new do |level, message|
    "%s %5s : %s" % [Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"), level.upcase, message]
  end

  # Syslog support.
  SYSLOG_SEVERITIES = {
    :fatal => 2,
    :error => 3,
    :warn  => 4,
    :info  => 6,
    :debug => 7
  }
  SYSLOG_FORMAT = Proc.new do |level, message|
    require "socket" unless defined?(Socket)
    "<%s>%s %s %s[%s]: %s" % [8 + SYSLOG_SEVERITIES[level], Time.now.strftime("%b %e %T"), Socket.gethostname, $0, Process.pid, message]
  end

  # Calculate ranks.
  RANKS = Hash[([:off] + LEVELS).each_with_index.map{|level, i| [level, i]}]

  def initialize(stream = STDOUT)
    self.level = DEFAULT_LEVEL
    self.format = DEFAULT_FORMAT
    @stream = stream
    begin
      @stream.sync = true if @stream.respond_to?(:sync=)
    rescue IOError
      # Do nothing.
    end
  end

  attr_reader :level

  def level=(level)
    @level = level.to_sym
    @rank = RANKS[@level]
    raise "Unknown log level: #{level}" unless @rank
  end

  attr_writer :format

  def format(&block)
    if block_given?
      @format = block
    else
      @format
    end
  end

  def <<(message)
    add(:info, message)
  end

  def add(level, message)
    if @rank >= RANKS[level]
      message = message.call if message.is_a?(Proc)
      message = @format.call(level, message)
      begin
        @stream.write message << "\n"
      rescue IOError
        # Do nothing.
      end
    end
  end

  # Add methods for each level.
  LEVELS.each do |level|
    class_eval %Q!
    def #{level}(message = nil, &block)
      message = block if block_given?
      add(:#{level}, message)
    end

    def #{level}?
      @rank >= #{RANKS[level]}
    end
    !
  end

  class << self

    def logify!(stream = STDOUT)
      @logger = StreamLogger.new(stream)
      $stdout = IOProxy.new(logger)
      Kernel.send :define_method, :logger do
        StreamLogger.logger
      end
    end

    def unlogify!
      $stdout = STDOUT
    end

    def logger
      @logger
    end

  end

end
