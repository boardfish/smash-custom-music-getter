require 'open-uri'
formats = { "brstm": ["Super Smash Bros. Brawl"], "bcstm": ["Tales of the Abyss", "Mario Kart 7", "Fire Emblem Awakening"], "nus3bank": ["Super Smash Bros. for 3DS", "Super Smash Bros. for Wii U"], "hps":["Super Smash Bros. Melee", "Kirby Air Ride"]}

formats.each do |filetype, gamelist|
  print filetype, ":"
  puts
  gamelist.each do |gameInFiletype|
    puts gameInFiletype
  end
end

game = gets.chomp
fileformat = ''

formats.each do |filetype, gamelist|
  gamelist.each do |gameInFiletype|
    if game == gameInFiletype
      print filetype, " found for ", game
      puts
      fileformat = filetype
    end
  end
end
File.open("smashpoint.txt").each do |line|
  input = URI.encode(line)
  code = line.split("/")
  code = code[code.length-1].chomp
  begin
    filename = "#{code}.#{fileformat}"
    new_filename = ''
    #raise "NaN" unless code.to_i>0
    open(filename, 'wb') do |file|
      open(URI.encode("http://smashcustommusic.com/#{fileformat}/" + code)) do |uri|
        fileinfo =  uri.metas["content-disposition"][0]
        new_filename = fileinfo[/(?<=filename=")[^\"]+/]
        file.write(uri.read)
      end
    end
    File.rename(filename, new_filename)
  rescue
    puts "Not found - must be a number or link that ends with one."
  end
end
