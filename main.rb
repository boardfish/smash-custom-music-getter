#SmashCustomMusicGetter v2.0
require 'open-uri'
formats = { "brstm": ["Super Smash Bros. Brawl"], "bcstm": ["Tales of the Abyss", "Mario Kart 7", "Fire Emblem Awakening"], "nus3bank": ["Super Smash Bros. for 3DS", "Super Smash Bros. for Wii U"], "hps":["Super Smash Bros. Melee", "Kirby Air Ride"]}

formats.each do |filetype, gamelist|
  print "#{filetype}:"
  puts
  gamelist.each do |gameInFiletype|
    print "#{gameInFiletype}, "
  end
  puts
end

game = gets.chomp
fileformat = ''
#choose a filetype/game.

#writing to csv

#parsing csv
fileformat = "nus3bank"
CSV.foreach("songlist.csv") do |row|
  #error handling for empty filename
  filename = "/#{row[1]}"
  songID = row[2]
  open("#{songID}.#{fileformat}", 'wb') do |file|
    open(URI.encode("http://smashcustommusic.com/#{fileformat}/#{songID}#{filename}")) do |uri|
      fileinfo =  uri.metas["content-disposition"][0]
      songtitle = fileinfo[/(?<=filename=")[^\"]+/]
      file.write(uri.read)
    end
  end
  File.rename("#{songID}.#{fileformat}", "#{filename}.#{fileformat}")
end
