class StreamLogger
  class IOProxy

    def initialize(io)
      @io = io.dup
    end

    def logger
      @logger ||= ::StreamLogger.new(@io)
    end

    def write(message)
      logger << message unless message == "\n"
    end

    def putc(int)
      logger << int
    end

    def puts(message)
      logger << message
    end

    def print(message)
      logger << message
    end

    def printf(*args)
      logger << sprintf(*args)
    end

    private

    def method_missing(method, *args)
      @io.respond_to?(method) ? @io.send(method, *args) : super
    end

  end
end
