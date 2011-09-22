class StreamLogger
  class IOProxy

    def initialize(logger)
      @logger = logger
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

    def logger
      @logger
    end

  end
end
