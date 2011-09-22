# StreamLogger

StreamLogger is a lightweight library that logs to any stream, like `stdout`.

Logging to a stream is **[much more powerful](http://adam.heroku.com/past/2011/4/1/logs_are_streams_not_files/)** than logging to a file.

## How to use

```ruby
require "stream_logger"

logger = StreamLogger.new(STDOUT)
logger.level = :debug   # Default is :info

logger.debug "It works!"
```

Simple enough!  Let's look at a more interesting example.

## Wouldn't it be great if...

You could access the logger from any class or module?

Output statements like `puts` are `print` were automatically logged?

```ruby
require "stream_logger"

StreamLogger.logify!

logger.warn "This is pretty awesome"
puts "This gets logged, too"
```

Output statements have a log level of `:info`.

## How to change the format

The default format looks like:

```
2011-09-20T02:43:43-0700  INFO : I'm informative
2011-09-20T02:43:44-0700  WARN : You've been warned
2011-09-20T02:43:44-0700 ERROR : Oh no!
```

You can change the format with:

```ruby
logger.format do |level, message|
  "%s %s %s %5s : %s" % [$0, Process.pid, Time.now, level, message]
end
```

For your convenience, StreamLogger comes with the syslog format.

```ruby
logger.format = StreamLogger::SYSLOG_FORMAT
```

## How to turn logging off

To turn logging off, use:

```ruby
logger.level = :off
```

## How to improve the performance of slow log messages

If you have logging code that takes a while to run, you can defer execution.
The code below won't execute unless `logger.level = :debug`.
This can save a lot of time in a production environment when the log level is set lower.

```ruby
logger.debug { sleep(5); "This code takes a while to run" }
```

Note: This is only faster for slow log messages. In most cases, use the regular method.

## How to direct output

Let's assume your program is executed with the command `mydaemon` and logs to `stdout`.

### stdout

```
mydaemon
```

### file

```
mydaemon >> log/mydaemon.log
```

### stdout and file

```
mydaemon | tee -a log/mydaemon.log
```

### syslog

```
mydaemon | logger
```

### tcp port

```
mydaemon > /dev/tcp/127.0.0.1/8000
```

### udp port

```
mydaemon > /dev/udp/127.0.0.1/514
```
