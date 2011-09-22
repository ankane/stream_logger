require "stream_logger/io_proxy"
require "stream_logger/syslog"
require "stream_logger/version"

class StreamLogger
  SEVERITIES = {
    :debug   => 0,
    :info    => 1,
    :warn    => 2,
    :error   => 3,
    :fatal   => 4,
    :unknown => 5
  }

  DEFAULT_FORMAT = Proc.new do |level, message|
    "%s %5s : %s" % [Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"), level.upcase, message]
  end

  def initialize(stream = STDOUT, level = :info)
    @stream    = stream
    @format    = DEFAULT_FORMAT
    self.level = level
  end

  attr_reader :level

  def level=(level)
    @level    = level.to_sym
    @level_nb = SEVERITIES[@level]
    raise "Unknown log level: #{level}" unless @level_nb
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
    if @level_nb <= SEVERITIES[level]
      message = message.call if message.is_a?(Proc)
      message = @format.call(level, message) if @format
      begin
        @stream.write message << "\n"
      rescue IOError
        # Do nothing.
      end
    end
  end

  # Add methods for each level.
  SEVERITIES.each do |level, level_nb|
    class_eval %Q!
    def #{level}(message = nil, &block)
      message = block if block_given?
      add(:#{level}, message)
    end

    def #{level}?
      @level_nb <= #{level_nb}
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
