class Playlist < ApplicationRecord
  has_many :suggested_songs
  has_many :authorizations
  has_many :users, through: :authorizations
  has_many :temp_users, through: :authorizations

  validates :name, :presence => true

  def self.create_access_code
    access_code = rand(999999)
    while Playlist.where(access_code: access_code).count > 0
      access_code = rand(999999)
    end
    return access_code
  end


end
