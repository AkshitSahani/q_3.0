class TempUser < ApplicationRecord
  has_many :votes
  has_many :suggested_songs
  has_many :authorizations
  has_many :playlists, through: :authorizations
end
