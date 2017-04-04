require 'sqlite3'

def create_database
    games = %{CREATE TABLE game (
              GameID INTEGER PRIMARY KEY,
              Title TEXT,
              Filetype TEXT,
              Console TEXT)
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
end

def insert_data
  games = %{INSERT INTO game (
    Title,
    Filetype,
    Console) VALUES (?,?,?)
}
  @db.execute games, "Super Smash Bros. Brawl", "brstm", "Wii"
  @db.execute games, "Super Smash Bros. for Wii U", "brstm", "Wii U"
  @db.execute games, "Super Smash Bros. for 3DS", "brstm", "3DS"
  @db.execute games, "Super Smash Bros. Melee", "hps", "GameCube"
  @db.execute games, "Super Smash Bros. Project M", "brstm", "Wii"
  @db.execute games, "Mario Kart 7", "bcstm", "3DS"
  @db.execute games, "Fire Emblem Awakening", "bcstm", "3DS"
  @db.execute games, "Tales of the Abyss", "bcstm", "3DS"
  @db.execute games, "Kirby Air Ride", "hps", "GameCube"
  @db.execute games, "Tales of Symphonia: Dawn of the New World", "hps", "GameCube" #unverified
  @db.execute games, "Guilty Gear XX Core", "hps", "GameCube" #unverified
end

@db = SQLite3::Database.open './songlists.sqlite'
create_database
insert_data
