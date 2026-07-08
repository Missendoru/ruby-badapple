begin
  require 'lz_string'
rescue LoadError
  puts "installing dependencies..."
  system('gem install lz_string')
  Gem.clear_paths 
  require 'lz_string'
  puts "dependencies downloaded"
end

require 'json'
require 'io/console'

txt = "Bad Apple!! script made by Natsumi Ushiromiya @ github.com/Missendoru"

if Gem.win_platform?
  system("title #{txt}")
  system("cls")
else
  print "\e]2;#{txt}\a\e[2J\e[H"
end

loop do
  puts "choose mode"
  puts "1. symbols"
  puts "2. gradient boxes"
  print "(1/2)?: "
  mode = STDIN.gets.strip
  f = nil
  
  if File.exist?('decframes.json')
    print "found existing frames,, reading json..."
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    dec = File.read('decframes.json')
    t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts " done (took #{(t2 - t1).round(3)} seconds)"
  else
    if !File.exist?('frames.txt')
      puts "frames.txt not found"
      gets
      exit
    end
    print "reading compressed file from disk..."
    str = File.read('frames.txt').strip
    puts " done (#{str.bytesize} bytes loaded)"

    print "decompressing lz-string archive... \n(you will only see this once, takes 1 min or less)"
    t1 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    dec = LZString::Base64.decompress(str)
    t2 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    if dec.nil? || dec.empty?
      puts "\npoop didnt decompress"
      exit
    end
    puts " done (took #{(t2 - t1).round(3)} seconds)"
    print "saving frames..."
    File.write('decframes.json', dec)
    puts "done"
  end
  
  print "parsing json..."
  f = JSON.parse(dec)
  len = f.length
  puts " done"
  puts "play?"
  STDIN.gets
  
  if File.exist?('audio.mp3')
    pid = spawn("ffplay -nodisp -autoexit -loglevel quiet audio.mp3")
  end
  print "\e[2J\e[H\e[?25l"
  st = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  src_chars = " ._+=:*#%@░▒▓█-"
  tgt_chars = " ░░▒▒▓▓███████ "
  
  loop do
    cur = ( (Process.clock_gettime(Process::CLOCK_MONOTONIC) - st) / (1.0 / 30) ).floor
    if cur < len - 15
      print "\e[H"
      frame_str = f[cur].to_s.gsub("\\n", "\n")
      if mode == "2"
        frame_str = frame_str.tr(src_chars, tgt_chars)
      end
      puts "\e[30;47m#{frame_str}\e[0m"
    else
      break
    end
    w = ((cur + 1) * (1.0 / 30)) - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - st)
    sleep(w) if w > 0
  end
  print "\e[?25h"
  if Gem.win_platform?
    system("cls")
  else
    print "\e[2J\e[H"
  end
  puts "\nagain?"
  STDIN.gets
end