class SuggestedSong < ApplicationRecord
  belongs_to :playlist
  belongs_to :user, optional: true
  belongs_to :temp_user, optional: true
  has_many :votes

    def self.next_song_id(playlist_id)
      songs = SuggestedSong.where(playlist_id: playlist_id).order(status: :asc, net_vote: :desc, id: :asc)
      songs.each do |song|
        if song.status == "que"
          @next_song = song.song_id
          return @next_song
        end
      end
      return 0
    end

    def self.next_song_record(playlist_id)
      songs = SuggestedSong.where(playlist_id: playlist_id).order(status: :asc, net_vote: :desc, id: :asc)
      songs.each do |song|
        if song.status == "que"
          return song.id
        end
      end
      return 0
    end

    def self.playlist_length(playlist_id)
      length = SuggestedSong.where(playlist_id: playlist_id).count
    end

    def self.playlist_songs(playlist_id)
      songs = SuggestedSong.where(playlist_id: playlist_id).order(status: :asc, net_vote: :desc, id: :asc)
    end

    def self.random_song
      rand_song_id = rand(3135500..3135600)
      random_song = HTTParty.get("https://api.deezer.com/track/#{rand_song_id}")
      rand_artist = random_song["artist"]["name"]
      rand_title = random_song["title"]
      return [rand_song_id, rand_artist, rand_title]
    end

    def self.selected_song(songid)
      song = HTTParty.get("https://api.deezer.com/track/#{songid}")
      song_artist = song["artist"]["name"]
      song_title = song["title"]
      song_id = songid
      return [song_id, song_artist, song_title]
    end

end
