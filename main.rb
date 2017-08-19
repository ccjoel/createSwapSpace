#!/usr/bin/env ruby



# ============================== Add swap script ==============================-
# Author: Joel Quiles
# Dependencies: Ruby 1.9.x
# version: 0.5



puts "Swap creation script.\n"


# ============================ GLOBAL HELPER FUNS ==============================
def checkSuccess(cmd)
  result = $?
  if result.exitstatus != 0
    puts "Error code #{result.exitstatus} in running last command. Aborting script."
    if cmd
      puts "Error msg: #{cmd}"
    end
    puts "Called by #{caller(0)}"
    exit 100
  end
end

def errorExit(exitCode)
  return exit exitCode
end

def appendToFile(fileNameWithPath, stringToAppend)
  File.open(fileNameWithPath, 'a') do |file|         # 'a' for append mode
    file.puts stringToAppend
  end
end


# ==============================-- START SCRIPT ==============================--




# ===============- STEP [1] : Check the System for Swap Information ==========--


totalLinesForSwap = `swapon -s | wc -l` # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used

puts "Current lines on swapon file: #{totalLinesForSwap}"

if totalLinesForSwap.to_i > 1 or File.directory?("/swapfile")
  puts "Swap space has already been allocated for this environment"
  errorExit 1
end

checkSuccess(totalLinesForSwap)

# Check the results of the free -m command,
# to see how much memory there is, plus to double-check swap
output = `free -m`
checkSuccess(output)
swapWord = output.split(" ")[17]
totalSwap = output.split(" ")[18]

if swapWord != "Swap:"
  puts "Free output in an unexpeted format"
  errorExit 2
end

puts "Total swap: #{totalSwap}"



#======= STEP [2] : Check Available Space on the Hard Drive / Partition ========

puts "Let's verify that there is enough space on drive to add swap space."


gb_available = `df -h | grep /dev/sda`
checkSuccess(gb_available)

linesAvailableForDiskSpace = `df -h | grep /dev/sda | wc -l`
checkSuccess(linesAvailableForDiskSpace)

if linesAvailableForDiskSpace != 1
  errorExit 7
end

gb_available = gb_available.split(" ")[3]

puts " GB Available on system: #{gb_available}"

if gb_available.to_i > 10
  puts "Enough disk space available to allocate 4G of swap space"
else
  puts "Less than 10G available, won't allocate swap space."
  errorExit 3
end

checkSuccess




# ====================- STEP [3] : Create a Swap File =========================-


# Create file for allocate swap space

checkSuccess(`fallocate -l 4G /swapfile`)





# =================== STEP [4] : Enabling the Swap File ========================


# Add correct rights to swap file
`chmod 600 /swapfile`

# Tell system this newly allocated should be of type swap

checkSuccess(`mkswap /swapfile`)

# Actually tell environment to use is swap!

checkSuccess(`swapon /swapfile`)

# Verify that swapon's new output contains the right swap params

totalLinesForSwap = `swapon -s | wc -l`              # swapon shows total swap space allocated
# If swapon output is just one line, there is not swap space being used
puts "Current lines from swapon -s, after swap creation: #{totalLinesForSwap}"

if totalLinesForSwap.to_i != 1
  errorExit 4
end

# Double check free to see that there is actually swap here
output = `free -m`

checkSuccess(output)

totalSwap = output.split(" ")[18]
puts "Total swap: #{totalSwap}"

if totalSwap.to_i == 0
  errorExit 5
end



# =================== STEP [5] Make the Swap File Permanent ====================


# Check that there's no swap allocated into fstab:

linesWithPermanentSwap = `cat /etc/fstab | grep swap | grep -v '#' | wc -l`
checkSuccess(linesWithPermanentSwap)

if linesWithPermanentSwap > 0
  errorExit 6
end

# Append the following line:
# /swapfile   none    swap    sw    0   0
# to this file: /etc/fstab
appendToFile '/etc/fstab' '/swapfile   none    swap    sw    0   0'
checkSuccess




# ==================== STEP [6] Tweak your Swap Settings =======================


# Verify swappiness of swap space (on kernel)
swappiness = `cat /proc/sys/vm/swappiness`

puts "Current system swappiness: #{swappiness}"

if swapiness.to_i != 10        # If swapiness is not 10, set swapiness of system
  puts "Updating swappiness of system to 10"

  checkSuccess(`sysctl vm.swappiness=10`)

  # Check that this variable `vm.swappiness` is not set in `/etc/sysctl.conf` file
  isSwappinessAddedToSysCtl = `cat /etc/sysctl.conf | grep vm.swappiness | grep -v "#" | wc -l`

  if isSwappinessAddedToSysCtl.to_i == 0
    # Add the swappines to /etc/sysctl.conf to make swapiness permanent on next boot
    appendToFile '/etc/sysctl.conf' 'vm.swappiness=10'
    # TODO: else, if it exists, but with wrong value...?
  end

end



# Verify the swap cache pressure
swapCachePressure = `cat /proc/sys/vm/vfs_cache_pressure` # ... is it 100? 50? should be 50...

# If cache pressure is not 50, set to 50:

if swapCachePressure.to_i != 50

  checkSuccess(`sysctl vm.vfs_cache_pressure=50`)

  # Verify that the pressure is not set in /etc/sysctl.conf
  isCachePressureAddedToSysCtl = `cat /etc/sysctl.conf | grep vm.vfs_cache_pressure | grep -v "#" | wc -l`

  # If it isn't set:
  if isCachePressureAddedToSysCtl.to_i == 0
    # vm.vfs_cache_pressure = 50 # in that file
    appendToFile '/etc/sysctl.conf' 'vm.vfs_cache_pressure=50'
  end

end

return exit 0
