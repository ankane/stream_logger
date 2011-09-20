# StreamLogger

StreamLogger is a super-lightweight library that logs to any stream, like `stdout`.

Inspired by [Logs Are Streams, Not Files](http://adam.heroku.com/past/2011/4/1/logs_are_streams_not_files/) by Adam Wiggins.

## How to install

```
gem install stream_logger
```

## How to use

```ruby
require "stream_logger"

logger = StreamLogger.new($stdout)
logger.level = :warn      # Default is :info

logger.debug "It works!"  # Won't appear
logger.info  "It works!"  # Won't appear
logger.warn  "It works!"
logger.error "It works!"
logger.fatal "It works!"
```

To turn logging off, use:

```ruby
logger.level = :off
```

## How to change the format

The default format looks like:

```
2011-09-20T02:43:45-0700  INFO : I'm informative
2011-09-20T02:43:44-0700  WARN : You've been warned
2011-09-20T02:43:44-0700 ERROR : Oh no!
```

You can change the format with:

```ruby
logger.format do |level, message|
  "%s %s %s %5s : %s" % [$0, Process.pid, Time.now, level, message]
end
```

## How to improve the performance of slow log messages

If you have logging code that takes a while to run, you can defer execution.
The code below won't execute unless `logger.level = :debug`.
This can save a lot of time in a production environment when the log level is set lower.

```ruby
logger.debug { sleep(5); "This code takes a while to run" }
```

Note: This is only faster for slow log messages. In most cases, use the regular method.

## How to direct the stream

Let's assume your program is executed with the command `mydaemon`.

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
