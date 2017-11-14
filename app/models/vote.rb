class Vote < ApplicationRecord
  belongs_to :suggested_song, class_name: 'SuggestedSong', foreign_key: 'suggestedsong_id'
  belongs_to :user, optional: true
  belongs_to :temp_user, optional: true

  def self.get_votes(playlist_id)
    # songs = SuggestedSong.where(playlist_id: playlist_id)
    #
    # users = []
    # songs.each do |song|
    #   users << song.user
    # end
    # users = users.uniq
    #
    #
    # votes = []
    # users.each do |user|
    #   user.votes.each do |vote|
    #     if songs.include?(vote.suggested_song)
    #       votes << vote
    #     end
    #   end
    # end
    # return votes
    votes = Vote.all
    return votes
  end
end
