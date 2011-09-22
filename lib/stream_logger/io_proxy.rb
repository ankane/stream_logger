class StreamLogger
  class IOProxy

    def initialize(logger)
      @logger = logger
    end

    def write(message)
      logger.info message unless message == "\n"
    end

    def putc(int)
      logger.info int
    end

    def puts(message)
      logger.info message
    end

    def print(message)
      logger.info message
    end

    def printf(*args)
      logger.info sprintf(*args)
    end

    private

    def logger
      @logger
    end

  end
end
