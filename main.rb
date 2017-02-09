#SmashCustomMusicGetter v2.0
require 'open-uri'
require 'csv'
require 'fileutils'
$formats = { "brstm": ["Super Smash Bros. Brawl"], "bcstm": ["Tales of the Abyss", "Mario Kart 7", "Fire Emblem Awakening"], "nus3bank": ["Super Smash Bros. for 3DS", "Super Smash Bros. for Wii U"], "hps":["Super Smash Bros. Melee", "Kirby Air Ride"], "mp3": ["mp3 previews shown on smashcustommusic"]}

def choose(formats)
  formats.each do |filetype, gamelist|
    print "#{filetype}:"
    puts
    gamelist.each do |gameInFiletype|
      print "#{gameInFiletype}, "
    end
    puts
  end
  fileformat = ""
  loop do
    isFiletype = false
    fileformat = gets.chomp
    formats.each do |filetype, gamelist|
      if fileformat == filetype.to_s
        puts "Matched!"
        isFiletype = true
        return fileformat
      end
    end
    puts "All checked. Please try again"
    print ": "
  end
  parse_csv
end
#choose a filetype/game.

#CLEAN CSV GENERATOR
def generate_csv
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
    puts "An error occurred. You've either deleted songlist.txt (don't touch that!) or done something with songlist.csv..."
  else
    puts "done! You now have an empty song list at songlist.csv."
  end
end

def download_song(songID, fileformat, filename, songnames)
  FileUtils::mkdir_p "output/#{fileformat}"
  open("output/#{fileformat}/#{filename}.#{fileformat}", 'wb') do |file|
    songtitle = ""
    puts "http://smashcustommusic.com/#{fileformat}/#{songID}"
    begin
      open(URI.encode("http://smashcustommusic.com/brstm/#{songID}")) do |uri| #locked to brstm here, to prevent issues with getting MP3 metadata.
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
      if fileformat == "mp3"
        downloadURL = "http://smashcustommusic.com/music/#{fileformat}/#{songID}.#{fileformat}"
      else
        downloadURL = "http://smashcustommusic.com/#{fileformat}/#{songID}/#{filename}"
      end
      open(URI.encode(downloadURL)) do |uri|
        file.write(uri.read)
      end
    rescue
      print "not replaced, error in download."
      File.delete("output/#{fileformat}/#{filename}.#{fileformat}")
      next
    else
      puts "replaced with #{songtitle}."
    end
    if songnames
      File.rename("output/#{fileformat}/#{filename}.#{fileformat}", "output/#{fileformat}/#{songtitle}.#{fileformat}")
    end
  end
end

def parse_csv
  begin
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
        next
      end
      print "#{row[1].chomp} "
      download_song(songID, $fileformat, filename, false)
    end
  rescue
    puts "An error occurred. Have you renamed songlist.csv to songlist1.csv?"
  else
    puts "All done! Check the output folder."
  end
end

def parse_txt
  File.open("songlist1.txt").each do |link|
    input = URI.encode(link)
    songID = link.split("/")
    songID = songID[songID.length-1].chomp
    download_song(songID, $fileformat, "", true)
  end
  puts "All done! Check the output folder."
end

def menu
  puts "SmashCustomMusicGetter, by undying-fish"
  print "Choose an option: "
  input = gets.chomp
  case input
  when "generate"
    generate_csv
  when "download"
    $fileformat = choose($formats)
    print "Choose an option [gamefile/title]: "
    input = gets.chomp
    case input
    when "gamefile"
      parse_csv
    when "title"
      parse_txt
    end
  when exit
    puts "Thank you for using this program!"
    return
  end
  menu
end

menu
