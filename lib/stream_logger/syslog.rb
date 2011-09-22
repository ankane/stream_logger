require "socket"

class StreamLogger
  SYSLOG_SEVERITIES = {
    :debug   => 7,
    :info    => 6,
    :warn    => 4,
    :error   => 3,
    :fatal   => 2,
    :unknown => 1
  }

  SYSLOG_FORMAT = Proc.new do |level, message|
    "<%s>%s %s %s[%s]: %s" % [8 + SYSLOG_SEVERITIES[level], Time.now.strftime("%b %e %T"), Socket.gethostname, $0, Process.pid, message]
  end
end
