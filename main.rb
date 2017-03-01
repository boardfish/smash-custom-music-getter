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
    puts
    print "All checked. Please try again"
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

def download_song(songID, fileformat, filename, directory)
  outputpath = directory+"/#{filename}.#{fileformat}"
  File.open(outputpath, 'wb') do |file|
    songtitle = ""
    begin
      if fileformat == "mp3"
        downloadURL = "http://smashcustommusic.com/music/#{fileformat}/#{songID}.#{fileformat}"
      else
        downloadURL = "http://smashcustommusic.com/#{fileformat}/#{songID}"
        if filename!=""
          downloadURL+="/#{filename}"
        end
      end
      open(URI.encode(downloadURL)) do |uri|
        file.write(uri.read)
      end
    rescue
      print "not replaced, error in download."
      File.delete(directory+"#{filename}.#{fileformat}")
      return set_directory("output", fileformat)
      next
    else
      puts "done!"
      return true
    end
  end
end

def get_song_title(songID)
    open(URI.encode("http://smashcustommusic.com/brstm/#{songID}")) do |uri| #locked to brstm here, to prevent issues with getting MP3 metadata.
      fileinfo =  uri.metas["content-disposition"][0]
      songtitle = fileinfo[/(?<=filename=")[^\"]+/]
      songtitle.slice! ".brstm"
      songtitle.gsub!(/[^0-9A-Za-z.\-]/, '_')
      return songtitle
    end
end

def parse_csv(originaltitles)
  begin
    CSV.foreach("songlist1.csv") do |row|
      songID = row[2].strip
      if songID.to_i == 0
        next
      end
      print "#{row[1].chomp} - "
      filename = row[0].strip
      if filename.eql? "" or filename.eql? "BrawlStage"
        next
      end
      if originaltitles
        filename = get_song_title(songID)
      end
      puts filename
      print("Downloading...")
      download_song(songID, $fileformat, filename, "output/#{$fileformat}")
      puts("Done!")
    end
  rescue
    puts "An error occurred. Have you renamed songlist.csv to songlist1.csv?"
  else
    puts "All done! Check the output folder."
  end
end

def parse_txt(directory)
  currentSubfolder=""
  File.open("songlist1.txt").each do |link|
    input = URI.encode(link)
    songID = link.split("/")
    songID = songID[songID.length-1].chomp
    begin
      filename=get_song_title(songID)
    rescue
      puts currentSubfolder
      unless currentSubfolder.nil? || currentSubfolder.empty?
        directory.slice! currentSubfolder
        puts "Sliced directory: " + directory
      end
      directory = set_directory(directory, link.chomp)
      currentSubfolder = "/" + link.chomp
      puts "Current subfolder: " + currentSubfolder
    else
      puts(filename)
      print("Downloading...")
      download_song(songID, $fileformat, filename, directory)
    end
  end
  puts "All done! Check the output folder."
end

def set_directory(root, *manualsort)
  directory = root
  manualsort.each do |subfolder|
    directory+= "/" + subfolder.chomp
  end
  FileUtils::mkdir_p directory
  puts directory
  return directory
end

def menu
  puts "SmashCustomMusicGetter, by undying-fish"
  print "Choose an option [generate/download]: "
  input = gets.chomp
  case input
  when "generate"
    generate_csv
  when "download"
    $fileformat = choose($formats)
    directory = set_directory("output", $fileformat)
    print "Choose an option [gamefile/title]: "
    input = gets.chomp
    case input
    when "gamefile"
      parse_csv(false)
    when "title"
      print "Choose an option [csv/txt]: "
      input = gets.chomp
      case input
      when "csv"
        parse_csv(true)
      when "txt"
        parse_txt(directory)
      end
    end
  when "exit"
    puts "Thank you for using this program!"
    return
  end
  menu
end

menu
