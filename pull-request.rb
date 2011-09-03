#!/usr/bin/env ruby

require 'rubygems'
#require 'git'
require 'gist'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: pull-request.rb -s|--subject receiver@email.com"
  opts.separator ""

  opts.on("-r", "--recipient [RECIPIENT]", "You must provide a recipient email!") do |r|
    options[:recipient] = r
  end

  opts.on("-s", "--sha [SHA]", "You must provide a SHA!") do |sha|
    options[:sha] = sha
  end

  opts.on("-u", "--url [URL]", "You must profile a url!") do |url|
    options[:url] = url
  end

  opts.on("-f", "--file [FILE]", "Provide a custom file name.") do |file|
    options[:file] = file
  end

  opts.on("-t", "--type [TYPE]", "Provide a custom type (extension as in .rb or .cpp) for syntax hilighting!") do |type|
    options[:type] = type
  end
end.parse!

# exit if no recipent is given
if (options[:recipient].nil? || options[:recipient].empty?) 
  puts "ERROR: You must provide a recipient email!"
  exit
elsif (options[:sha].nil? || options[:sha].empty?) 
  puts "You must provide a SHA!"
  exit
elsif (options[:url].nil? || options[:url].empty?) 
  puts "You must provide a url!"
  exit
elsif (options[:file].nil? || options[:file].empty?) 
  options[:file] = "rp.txt"
elsif (options[:type].nil? || options[:type].empty?) 
  puts "No type provided, falling back to ruby!"
  options[:type] = "rb"
end

# set filename
options[:filename] = "#{options[:file]}.#{options[:type]}"

puts options

#actual code! :D
if system("git request-pull -p #{options[:sha]} #{options[:url]} > #{options[:filename]}")

  # gets the gist link
  IO.popen("gist << #{options[:filename]}") { |io| while (line = io.gets) do gist = line end }

  # mails gist link to recipient
  if system("mail -s \"[Pull Request]#{options[:msg] ||= options[:sha]}\" #{options[:recipient]} < #{gist}")
    puts "Success!"
    exit
  else
    puts "Something went wrong sending email!"
    exit
  end
else
  puts "Something went wrong running git!"
  exit
end
#mail -s "[Pull Request]#{msg}" options[:recipient] < pull_request_content + gist_url

#git request-pull -p 63999b6af821859e4dc8c474101bacee309e2d6f git@codeplane.com:elland/pixplx.git > RP.txt