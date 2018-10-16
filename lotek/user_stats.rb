require './log_parse'
require 'pry'
require 'colorize'
# Parse the command line
src_access_log=""

options = {}
begin
  opts = OptionParser.new
  opts.banner = "Usage: #{$PROGRAM_NAME} [options] ..."
  opts.separator ''
  opts.separator 'Options:'
  opts.on('-s src_access_log',
          '--src_access_log src_access_log',
          String,
          'Set source access log file') {|key| options[:src_access_log] = key}

  opts.on('-d src_access_log_dir',
          '--src_access_log_dir src_access_log_dir',
          String,
          'Set source access log file directory') {|key| options[:src_access_log_dir] = key}
  opts.on('-h', '--help', 'Show this message') do
    puts opts
    exit
  end
rescue OptionParser::ParseError
  puts "Oops... #{$!}"
  puts opts
  exit
end

begin
  opts.parse!
  mandatory = [:src_access_log, :src_access_log_dir]      # Enforce the presence of
  missing = mandatory.select{ |param| options[param].nil? }
  if not missing.length==1
    puts "Missing options: #{missing.join(', ')}"
    puts opts
    exit -1
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts opts#
  exit -1
end

if (options[:src_access_log])
  requests = AWSELBAccessLogParser.new().parse_log_file(options[:src_access_log])
end

if (options[:src_access_log_dir])
  files = Dir.entries(options[:src_access_log_dir]).select {|f| !File.directory? f}
  requests = files.reduce([]) {|accumulator, file| accumulator.concat AWSELBAccessLogParser.new().parse_log_file("#{options[:src_access_log_dir]}/#{file}" ) }
end
byuser= requests.group_by {|r| r.client }

users = byuser.keys

puts "Users total: #{users.length}"
puts "Requests total: #{requests.length}"
exit

# [:timestamp, :elb, :client, :client_port, :backend, :backend_port, :request_processing_time, :backend_processing_time, :response_processing_time, :elb_status_code, :backend_status_code, :received_bytes, :sent_bytes, :request, :user_agent, :ssl_cipher, :ssl_protocol]
byuser.each do |user, user_requests|
  # each user has N requests, requests have the above keys/methods
  # so
  sorted_requests = user_requests.sort_by { |req| req.timestamp }
  puts user.white
  puts "[request_started, seconds_since_previous_request, request, target_response_time]"
  previous_timestamp=DateTime.parse(sorted_requests.first.timestamp)
  sorted_requests.each do |r|
    time_between = ((DateTime.parse(r.timestamp)-previous_timestamp) *24*60*60).to_i
    if (time_between>0 or r==sorted_requests.first)
      print "  #{r.timestamp}".red,  " (+#{time_between}s) ".blue, "#{r.request}".white, " #{r.backend_processing_time}\r\n".cyan
    end
    previous_timestamp = DateTime.parse(r.timestamp)
  end
end

## Hat tip : https://gist.github.com/jibing57/ea180bfc3f7cb96e4a1fa67aa7a7c0c2
