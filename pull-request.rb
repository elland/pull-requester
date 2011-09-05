#!/usr/bin/env ruby

require 'rubygems'
#require 'git'
require 'gist'
require 'optparse'


def main
  #assigns readme to @help
  load_help

  # break flow and return help if no options were passed
  if ARGV.size.zero?
    puts @help
    exit
  end
  
  # parse options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: pull-request.rb -s|--subject receiver@email.com"

    opts.on("--recipients x,y,z", Array, "You must provide a list of recipient emails!") do |recipients|
      options[:recipient] = recipients.join(', ')
    end

    opts.on("-s", "--sha [SHA]", "You must provide a SHA!") do |sha|
      options[:sha] = sha
    end

    opts.on("-u", "--url [URL]", "You must profile a url!") do |url|
      options[:url] = url
    end
    
    # asks for help
    opts.on("-h", "--help", @help) do |help|
      options[:help] = help
    end
  end.parse!

  #if asked for help
  if options[:help]
    puts @help
    exit
  end
  puts options[:recipient]
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
  end

  #puts options

  #actual code! :D
  begin
    diff = ""
    IO.popen("git request-pull -p #{options[:sha]} #{options[:url]}") {|io| while (line = io.gets) do diff += line  end}
    #dumps diff to escape all chars
    diff_dump = diff.dump
    # gets the gist link
    system( "echo #{diff_dump} | gist -t diff > /tmp/pull_request_diff_gist_buffer" )
    
    # mails gist link to recipient
    if system("mail -E -s \"[Pull Request]  #{options[:msg] || options[:sha]}\" -c #{options[:recipient]} < /tmp/pull_request_diff_gist_buffer")
      puts "Success!"
      exit
    else
      puts "Something went wrong sending email!"
      exit
    end
  rescue
    puts "Something went wrong running git!"
    exit and return
  end
end


def load_help
  @help = <<END
  Options:  

  -r    --recipent    "email receiver"  

  -s    --sha SHA     "start commit SHA"  

  -u    --url URL     "repo url"  

END
end


if true
  main
end