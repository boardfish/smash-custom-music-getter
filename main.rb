#SmashCustomMusicGetter v2.0
require 'open-uri'
require 'csv'
formats = { "brstm": ["Super Smash Bros. Brawl"], "bcstm": ["Tales of the Abyss", "Mario Kart 7", "Fire Emblem Awakening"], "nus3bank": ["Super Smash Bros. for 3DS", "Super Smash Bros. for Wii U"], "hps":["Super Smash Bros. Melee", "Kirby Air Ride"]}
require 'fileutils'

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

#CLEAN CSV GENERATOR
print("Reading songlist.txt...")
begin
  CSV.open("songlist.csv", "wb") do |csv|
    File.open("songlist.txt", "r").each do |line|
      filename = line.split("|")[0]
      songname = line.split("|")[1]
      csv << [filename, songname, 0]
    end
  end
rescue
  puts "An error occurred."
else
  puts "done! You now have an empty song list at songlist.csv."
end
#writing to csv

#parsing csv
fileformat = "nus3bank"
CSV.foreach("songlist1.csv") do |row|
  filename = row[0].strip
  if filename.eql? "" or filename.eql? "BrawlStage"
    puts "-------------------"
    puts "#{row[1]}"
    puts "-------------------"
    next
  end
  songID = row[2].strip
  if songID.to_i == 0
    #puts "Song not defined for #{row[1]}"
    next
  end
  print "#{row[1].chomp} "
  #Start MP3 download
  FileUtils::mkdir_p "output/#{fileformat}"
  open("output/#{fileformat}/#{filename}.#{fileformat}", 'wb') do |file|
    songtitle = ""
    begin
      open(URI.encode("http://smashcustommusic.com/#{fileformat}/#{songID}")) do |uri|
        fileinfo =  uri.metas["content-disposition"][0]
        songtitle = fileinfo[/(?<=filename=")[^\"]+/]
      end
    rescue
      puts
      puts "ERROR: Song not found."
      File.delete("output/#{fileformat}/#{filename}.#{fileformat}")
      next
    end
    begin
      open(URI.encode("http://smashcustommusic.com/#{fileformat}/#{songID}/#{filename}")) do |uri|
        file.write(uri.read)
      end
    rescue
      print "not replaced, error in download."
      File.delete("output/#{fileformat}/#{filename}.#{fileformat}")
      next
    else
      puts "replaced with #{songtitle}."
    end
  end
  #Start MP3 download
  FileUtils::mkdir_p 'output/mp3'
  open("output/mp3/#{filename}.mp3", 'wb') do |file|
    begin
      open(URI.encode("http://smashcustommusic.com/music/mp3/#{songID}.mp3")) do |uri|
        file.write(uri.read)
      end
    rescue
      puts "MP3 download failed."
      File.delete("output/mp3/#{filename}.mp3")
    else
      puts "MP3 download successful."
    end
  end
end
