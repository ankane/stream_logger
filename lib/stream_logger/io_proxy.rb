class StreamLogger
  class IOProxy

    def initialize(logger)
      @logger = logger
    end

    # Don't need print or printf.

    def write(message)
      logger.info message unless message == "\n"
    end

    def putc(obj)
      logger.info obj
    end

    def puts(*args)
      args = [""] if args.empty?
      args.each { |arg| logger.info arg }
    end

    private

    def method_missing(method, *args, &block)
      IO.method_defined?(method) || super
    end

    def logger
      @logger
    end

  end
end
