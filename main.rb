#SmashCustomMusicGetter v2.0
require 'open-uri'
require 'csv'
require 'fileutils'
require 'sqlite3'

def choose
  begin
      @db.results_as_hash = true
      gamelist = @db.execute %{SELECT * FROM game}
  rescue SQLite3::SQLException => e
      puts "Table does not exist"
      puts e
  end
  gamelist.each do |game|
    print game["GameID"], ": ", game["Filetype"]
    puts
  end
  selection = 0
  isFiletype = false
  while !isFiletype
    fileformat = gets.chomp.to_i
    games = @db.execute("SELECT Filetype FROM game WHERE GameID = ?", fileformat)
    if games.length>0
      puts "Matched!"
      isFiletype = true
      return games[0]["Filetype"]
    end
    print "All checked. Please try again: "
  end
  parse_csv
end
#choose a filetype/game.

#CLEAN CSV GENERATOR/DATABASE GENERATOR?
def generate(file)
  begin
      @db.results_as_hash = true
      gamelist = @db.execute %{SELECT * FROM game}
  rescue SQLite3::SQLException => e
      puts "Table does not exist"
      puts e
  end
  gamelist.each do |game|
    print game["GameID"], ": ", game["Title"], "\n"
  end
  input = -1
  chosenSonglist = ""
  loop do
    # begin
      input = gets.chomp.to_i
      chosenSonglist = @db.execute %{SELECT * FROM game WHERE GameID = ?}, input
      chosenSonglist = chosenSonglist[0]
    # rescue
      # puts "That's not valid. Try again."
    # else
      break
    # end
  end
  puts chosenSonglist["Title"]
  inputtxtfile = "songlists/" + chosenSonglist["Title"].gsub(/[.,\/#!$%\^&\*;:{}=\-_`~()]/,"").gsub(/\s+/, '')
  inputtxtfile = inputtxtfile+".txt"
  case file
  when "csv"
    begin
      CSV.open("songlist.csv", "wb") do |csv|
        File.open("#{inputtxtfile}", "r").each do |line|
          filename = line.split("|")[0]
          songname = line.split("|")[2]
          csv << [filename, songname, 0] #INSERT INTO songlist (InGameFileName, Title)
        end
      end
    rescue
      puts "An error occurred. You've either deleted songlist.txt (don't touch that!) or done something with ..."
    else
      puts "done! You now have an empty song list at songlist.csv."
    end
  when "sqlite"
    begin
      gameID = @db.execute %{ SELECT GameID FROM game WHERE title = "#{chosenSonglist["Title"]}" }
      gameID = gameID[0]["GameID"].to_i
      File.open("#{inputtxtfile}", "r").each do |line|
        puts
        print line
        filename = line.split("|")[0].chomp
        shortname = line.split("|")[1].chomp
        if filename != "BrawlStage"
          songname = line.split("|")[2].chomp
          puts "INSERT INTO songlist (InGameFileName, Title, ShortFileName, GameID) VALUES (?,?,?,?)", filename,songname,shortname,gameID
          @db.execute "INSERT INTO songlist (InGameFileName, Title, ShortFileName, GameID) VALUES (?,?,?,?)", filename,songname,shortname,gameID
        end
      end
      puts "done! You now have a database at songlist.sqlite."
    rescue SQLite3::Exception => e
      puts "An error occurred."
      puts e
    ensure
      @db.close if @db
    end
  end
end

def download_song(songID, fileformat, filename, directory)
  outputpath = directory+"/#{filename}.#{fileformat}"
  print "Downloading #{filename}..."
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
      puts "failed!"
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

def verify(row)
  if row[2].chomp.to_i == 0
    if row[0].chomp == "BrawlStage"
      print "STAGE"
      if !row[1].nil?
        print ": ", row[1].chomp
      end
      puts
    end
    return false
  else
    (0..3).each do |i|
      print row[i].chomp if !row[i].nil?
      if i%2==0
        print " - "
      else
        if i!=3
          print " | "
        end
      end
    end
    puts
    return true
  end
  return false
end

def parse_csv(originaltitles)
  begin
    CSV.foreach("songlist1.csv") do |row|
      if verify(row)
        songID = row[2].chomp.to_i
        filename = row[0].chomp
        download_song(songID, $fileformat, filename, "output/#{$fileformat}")
      elsif row[0].chomp == "BrawlStage"
        print "STAGE"
        if !row[1].nil?
          print ": ", row[1].chomp
        end
        puts
      end
    end
  rescue => e
    puts "An error occurred. Have you renamed songlist.csv to songlist1.csv?"
    puts e
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
  puts "SmashCustomMusicGetter, by boardfish"
  print "Choose an option [generate/download]: "
  input = gets.chomp
  case input
  when "generate"
    generate("csv")
  when "download"
    $fileformat = choose
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

begin
  @db = SQLite3::Database.open "songlists.sqlite"
  #generate("sqlite")
  menu
ensure
  @db.close
end
# CSV.foreach("songlist1.csv") do |row|
#   verify(row)
# end
