#!/usr/bin/env ruby

require 'sys/filesystem'

#Dependencies: Ruby 1.9.x

# Add swap script


# Author: Joel Quiles

puts "Testing script"

def checkSuccess()
  if `echo $?` != 0
		puts "Error in running last command. Aborting script."
	end
end

puts `echo $LINENO`

totalLinesForSwap = `sudo swapon -s | wc -l`              # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used
puts "Current lines on swapon file: #{totalLinesForSwap}"


if totalLinesForSwap.to_i > 1 or File.directory?("/swapfile")
	puts "Swap space has already been allocated for this environment"
	#exit 1
end

# Check the results of the free -m command, to see how much memory there is, plus to double-check swap
output = `free -m`
swapWord = output.split(" ")[17]
totalSwap = output.split(" ")[18]

if swapWord != "Swap:"
	puts "Free output in an unexpeted format"
	#exit 2
end

puts "Let's verify that there is enough space on drive to add swap space"

stat = Sys::Filesystem.stat("/")
gb_available = stat.block_size * stat.blocks_available / 1024 / 1024 / 1024

puts gb_available.to_s + "G"

if gb_available > 10
	puts "Enough disk space available to allocate 4G of swap space"
else
	puts "Less than 10G available, won't allocate swap space."
	#exit 3
end

checkSuccess

# TODO: allocate swap space

# sudo fallocate -l 4G /swapfile

# TODO: add correct rights to swap file

# sudo chmod 600 /swapfile

# TODO: tell system this newly allocated should be of type swap

# sudo mkswap /swapfile

# TODO: verify exit code of last command by comparing $? to 0

# TODO: Actually tell environment to use is swap!

# sudo swapon /swapfile

# TODO: Verify that swapon's new output contains the right swap params

# sudo swapon -s

# TODO: double check free to see that there is actually swap here

# free -m

# TODO: Make the Swap File Permanent

# Append the following line:
# /swapfile   none    swap    sw    0   0
# to this file: /etc/fstab

# TODO: verify swapiness of swap space (on kernel)

# cat /proc/sys/vm/swappiness

# TODO: set swapiness of system

# sudo sysctl vm.swappiness=10

# TODO: check that this variable `vm.swappiness` is not set in `/etc/sysctl.conf` file

# TODO: Add the swappines to /etc/sysctl.conf to make swapiness permanent on next boot

# vm.swappiness=10

# TODO: verify the swap cache pressue
# cat /proc/sys/vm/vfs_cache_pressure... is it 100? 50? should be 50...

# TODO: if cache pressure is not 50, set to 50:

# sudo sysctl vm.vfs_cache_pressure=50

# TODO: verify that the pressure is not set in /etc/sysctl.conf
# vm.vfs_cache_pressure?

# TODO: if it isnt' set:

# vm.vfs_cache_pressure = 50 # in that file
