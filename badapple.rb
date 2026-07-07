require 'json'
require 'lz_string'
require 'io/console'

txt = "Bad Apple!! script made by Natsumi Ushiromiya @ github.com/Missendoru"
if Gem.win_platform?
  system("title #{txt}")
  system("color 70") 
  system("cls")
else
  print "\e]2;#{txt}\a\e[30;47m\e[2J\e[H"
end

if !File.exist?('frames.txt')
  puts "oop"
  gets
  exit
end

print "reading file from disk"
str = File.read('frames.txt').strip
puts " done (#{str.bytesize} bytes loaded)"

print "decompressing LZ-String archive"
t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
dec = LZString::Base64.decompress(str)
t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)

if dec.nil? || dec.empty?
  puts "\npoop didnt decompress"
  exit
end

puts "done  (took #{(t2 - t1).round(3)} seconds)"
print "parsing json"
f = JSON.parse(dec)
len = f.length

len.times do |i|
  print "\rloaded  #{i + 1} frames out of #{len} total frames"
end
puts "\ndone"

puts "play?"
STDIN.gets

if File.exist?('audio.mp3')
  pid = spawn("ffplay -nodisp -autoexit -loglevel quiet audio.mp3")
end

print "\e[2J\e[H\e[?25l"
st = Process.clock_gettime(Process::CLOCK_MONOTONIC)

loop do
  cur = ( (Process.clock_gettime(Process::CLOCK_MONOTONIC) - st) / (1.0 / 30) ).floor
  if cur < len
    print "\e[H"
    puts f[cur].to_s.gsub("\\n", "\n")
  else
    break
  end
  w = ((cur + 1) * (1.0 / 30)) - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - st)
  sleep(w) if w > 0
end

print "\e[?25h"
puts "\ndone"