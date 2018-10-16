require 'optparse'
require 'ostruct'

class AWSELBAccessLogParser

  def initialize()
    @@elb_access_log_format=%Q(timestamp elb client:port backend:port request_processing_time backend_processing_time response_processing_time elb_status_code backend_status_code received_bytes sent_bytes "request" "user_agent" ssl_cipher ssl_protocol)
    # puts "elb_access_log_format is #{elb_access_log_format.split(" ")}"

    @@line_regex = /
    (?<timestamp>[^ ]*)                                                                    # timestamp
    \s+(?<elb>[^ ]*)                                                                       # elb
    \s+(?<client>[^ ]*):(?<client_port>[0-9]*)                                             # client:port
    \s+(?<backend>[^ ]*):(?<backend_port>[0-9]*)                                           # backend:port
    \s+(?<request_processing_time>[-.0-9]*)                                                # request_processing_time value: 0.000056 or -1
    \s+(?<backend_processing_time>[-.0-9]*)                                                # backend_processing_time value: 0.093779 or -1
    \s+(?<response_processing_time>[-.0-9]*)                                               # response_processing_time value: 0.000049 or -1
    \s+(?<elb_status_code>-|[0-9]*)                                                        # elb_status_code
    \s+(?<backend_status_code>-|[0-9]*)                                                    # backend_status_code
    \s+(?<received_bytes>[-0-9]*)                                                          # received_bytes
    \s+(?<sent_bytes>[-0-9]*)                                                              # sent_bytes
    # \s+\"(?<request_method>[^ ]*)\s+(?<request_uri>[^ ]*)\s+(?<request_version>- |[^ ]*)\" # request section
    \s+\"(?<request>[^ ]*\s+[^ ]*\s+[^ ]*)\"                                               # entire request
    \s+\"(?<user_agent>[^ ]*.*[^ ]*)\"                                                  # entire user_agent
    \s+(?<ssl_cipher>[^ ]*)                                                                # ssl_cipher
    \s+(?<ssl_protocol>[^ ]*)                                                              # ssl_protocol
    /x
  end

  def parse_line(line)
    return nil if line.nil?
    line.match(@@line_regex)
  end

  def parse_log_file(src_file)
    if src_file.nil?
      puts "please entry the right src_file"
      return false
    end
    lines = []


    if !File.readable?(src_file)
      puts "src_file[#{src_file}] is not readable"
      return false
    end

    # parse the log file and store to dest csv file
    File.open(src_file, "r").each do |line|
      parts = parse_line(line)
      if parts == nil
        puts "Error -- Can't parse line [#{line}]"
        next
      end
      line_csv_array=OpenStruct.new
      parts.names.each { |filed_name| line_csv_array[filed_name] = parts[filed_name] }
      lines << (line_csv_array)
    end
    return lines
  end
end

## Hat tip : https://gist.github.com/jibing57/ea180bfc3f7cb96e4a1fa67aa7a7c0c2
