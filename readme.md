# SmashCustomMusicGetter

## Usage

Install the latest version of Ruby, and clone this repository. Run the script once (run `ruby main.rb` while in the directory) to generate a csv file. You can then edit this by entering song IDs from SmashCustomMusic (e.g. smashcustommusic.com/**1111**). Rename `songlist.csv` to `songlist1.csv`, and run the script one more time with `ruby main.rb | tee replacedsongs.txt`. `replacedsongs.txt` will now hold all replaced songs.
Additionally, you can create songlist1.txt, and drop links to smashcustommusic or song IDs directly in there. While using Title Mode, songs from that file will download with their original titles.

## Current features

- Download songs for Super Smash Bros. for Wii U song replacement, with the correct filenames!
- Download in any format available on SmashCustomMusic, including MP3!
- Download songs with their original titles for recreational use!

## Upcoming features

- Web app version.
- Song lists for all games on SmashCustomMusic.

## Help out!

Fork the project, make any necessary edits, and file a merge request. You're welcome to work on any features I haven't already mentioned here. That said, I'll probably throw you more privileges if you can help me out with the chore of building song lists for all games on SmashCustomMusic!
