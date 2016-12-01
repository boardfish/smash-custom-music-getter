require 'open-uri'
File.open("smashpoint.txt").each do |line|
  input = URI.encode(line)
  code = line.split("/")
  code = code[code.length-1].chomp
  begin
    filename = "#{code}.brstm"
    new_filename = ''
    raise "NaN" unless code.to_i>0
    open(filename, 'wb') do |file|
      open(URI.encode("http://smashcustommusic.com/brstm/" + code)) do |uri|
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
