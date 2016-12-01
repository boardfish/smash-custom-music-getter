require 'open-uri'
File.open("smashpoint.txt").each do |line|
  input = URI.encode(line)
  code = line.split("/")
  code = code[code.length-1].chomp
  filename = "#{code}.brstm"
  puts filename
  open(filename, 'wb') do |file|
    file << open(URI.encode("http://smashcustommusic.com/brstm/" + code)).read
  end
end
