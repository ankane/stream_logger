require "stream_logger/version"

class StreamLogger
  LEVELS = [:fatal, :error, :warn, :info, :debug]
  DEFAULT_LEVEL = :info
  DEFAULT_FORMAT = Proc.new do |level, message|
    "%s %5s : %s" % [Time.now.strftime("%Y-%m-%dT%H:%M:%S%z"), level.upcase, message]
  end

  def initialize
    @ranks = {}
    ([:off] + LEVELS).each_with_index do |name, i|
      @ranks[name] = i
    end
    self.level = DEFAULT_LEVEL
    self.format &DEFAULT_FORMAT
    $stdout.sync = true
  end

  attr_reader :level

  def level=(level)
    @level = level.to_sym
    @rank = @ranks[@level]
    raise "Unknown log level: #{level}" unless @rank
  end

  def format(&block)
    @format = block
  end

  LEVELS.each do |level|
    class_eval %Q!
    def #{level}(message = nil, &block)
      message = block if block_given?
      add(:#{level}, message)
    end
    !
  end

  protected

  def add(level, message)
    if @rank >= @ranks[level]
      message = message.call if message.is_a?(Proc)
      $stdout.print @format.call(level, message) << "\n"
    end
  end

end
