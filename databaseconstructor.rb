require 'sqlite3'

def create_database
    games = %{CREATE TABLE game (
              GameID INTEGER PRIMARY KEY,
              Title TEXT,
              FiletypeID INTEGER,
              Console TEXT)
}

    filetypes = %{CREATE TABLE filetype (
              FiletypeID INTEGER PRIMARY KEY,
              Title TEXT,
              Extension TEXT)
}

    songs = %{CREATE TABLE songlist (
              SongID INTEGER PRIMARY KEY,
              Title TEXT,
              InGameID TEXT,
              InGameFileName TEXT NOT NULL,
              GameID INTEGER NOT NULL,
              ShortFileName TEXT,
              FOREIGN KEY (GameID) REFERENCES game(GameID))
}

    @db.execute games
    @db.execute songs
    @db.execute filetypes
end

def insert_data
  filetypes = %{INSERT INTO filetype (
    Title,
    Extension) VALUES (?,?)
}
  games = %{INSERT INTO game (
    Title,
    FiletypeID,
    Console) VALUES (?,?,?)
}
  @db.execute filetypes, "brstm", "brstm"
  @db.execute filetypes, "bcstm", "bcstm"
  @db.execute filetypes, "hps", "hps"
  @db.execute filetypes, "mp3", "mp3"
  @db.execute games, "Super Smash Bros. Brawl", "0", "Wii"
  @db.execute games, "Super Smash Bros. for Wii U", "0", "Wii U"
  @db.execute games, "Super Smash Bros. for 3DS", "0", "3DS"
  @db.execute games, "Super Smash Bros. Melee", "2", "GameCube"
  @db.execute games, "Super Smash Bros. Project M", "0", "Wii"
  @db.execute games, "Mario Kart 7", "1", "3DS"
  @db.execute games, "Fire Emblem Awakening", "1", "3DS"
  @db.execute games, "Tales of the Abyss", "0", "3DS"
  @db.execute games, "Kirby Air Ride", "2", "GameCube"
  @db.execute games, "Tales of Symphonia: Dawn of the New World", "2", "GameCube" #unverified
  @db.execute games, "Guilty Gear XX Core", "2", "GameCube" #unverified
end

@db = SQLite3::Database.open './songlists.sqlite'
create_database
insert_data
