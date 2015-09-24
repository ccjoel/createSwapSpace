#!/usr/bin/env ruby -w

#Dependencies: Ruby 1.9.x

# Add swap script

# Author: Joel Quiles

puts "Testing script"

totalLinesForSwap = `sudo swapon -s | wc -l`              # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used
puts "Current lines on swapon file: #{totalLinesForSwap}"


if totalLinesForSwap.to_i > 1 or File.directory?("/swapfile")
	puts "Swap space has already been allocated for this environment"
	exit 1
end

# Check the results of the free -m command, to see how much memory there is, plus to double-check swap
output = `free -m`
swapWord = output.split(" ")[17]
totalSwap = output.split(" ")[18]

if swapWord != "Swap:"
	puts "Free output in an unexpeted format"
	exit 2
end

puts "Let's verify that there is enough space on drive to add swap space"

require 'sys/filesystem'

stat = Sys::Filesystem.stat("/")
gb_available = stat.block_size * stat.blocks_available / 1024
