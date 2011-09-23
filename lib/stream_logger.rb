require "stream_logger/io_proxy"
require "stream_logger/syslog"
require "stream_logger/version"

class StreamLogger
  LEVELS = {
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
    begin
      @stream.sync = true if @stream.respond_to?(:sync)
    rescue IOError
    end
  end

  attr_reader :level
  attr_writer :format

  def level=(level)
    @level    = level.to_sym
    @level_nb = @level == :off ? 99 : LEVELS[@level]
    raise "Unknown log level: #{level}" unless @level_nb
  end

  def format(&block)
    if block_given?
      @format = block
    else
      @format
    end
  end

  def add(level, message = nil, &block)
    return if @level_nb > LEVELS[level]
    message = (message || (block && block.call)).to_s

    # Ensure no newline before formatting.
    message.chomp! if message[-1] == "\n"
    message = @format.call(level, message) if @format

    # If a newline is necessary then create a new message ending with a newline.
    # Ensures that the original message is not mutated.
    message = "#{message}\n" unless message[-1] == ?\n

    # Attempt write.
    begin
      @stream.write(message)
    rescue IOError
    end

    message
  end

  def <<(message)
    add(:info, message)
  end

  # Add methods for each level.
  LEVELS.each do |level, level_nb|
    class_eval %Q!
    def #{level}(message = nil, &block)
      add(:#{level}, message, &block)
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
