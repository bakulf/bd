#!/usr/bin/env ruby

=begin
  bdutils - my deamon
=end

require 'rubygems'
require 'optparse'
require 'socket'

class BdUtilsBase
  attr_accessor :inputs

  def usocket(what)
    begin
      socket = UNIXSocket.open BdUtils::USOCKET_FILE
      return false if socket == -1
    rescue
      return false
    end

    socket.write what
    return
  end
end

class BdUtilsTime < BdUtilsBase
  def run
    return usocket "time"
  end
end

class BdUtilsBattery < BdUtilsBase
  def run
    charging = false
    capacity = ''
    time = ''
    output = ""

    IO.popen("acpitool -b") do |a| output += a.read end
    output.split("\n").each do |line|
      next unless line.include? ':'

      parts = line.split(':', 2)
      parts = parts[1].strip.split(',')
      return if parts.length < 3

      charging = parts[0].strip == 'Charging'
      capacity = parts[1].strip
      time = parts[2].strip
    end

    return usocket "notify #{charging ? "Charging" : "Discharging" }, #{capacity}, #{time}"
  end
end

class BdUtils
  LIST = [ { :cmd => 'time', :class => BdUtilsTime },
           { :cmd => 'battery', :class => BdUtilsBattery }, ]
  USOCKET_FILE = '/tmp/bterm.socket'
end

# a description of what this app can do:

options = {}
opts = OptionParser.new do |opts|
  opts.banner = "Usage: bxr [options] <operation> <something>"
  opts.version = '0.1'

  opts.separator ""
  opts.separator "Operations:"
  opts.separator "- time"
  opts.separator "  Show the date/time"

  opts.separator ""
  opts.separator "BSD license - Andrea Marchesini <baku@ippolita.net>"
  opts.separator ""
end

# I don't want to show exceptions if the params are wrong:
begin
  opts.parse!
rescue
  puts opts
  exit
end

task = nil

if ARGV.empty?
  puts opts
  exit
end


if ARGV.empty?
  puts opts
  exit
end

# task selection
op = nil
BdUtils::LIST.each do |c|
  if c[:cmd].start_with? ARGV[0]
    op = c
    break
  end
end

if op.nil?
  puts opts
  exit
end

task = op[:class].new
ARGV.shift
task.inputs = ARGV
task.run

