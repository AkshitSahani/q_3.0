class User < ApplicationRecord
  has_secure_password

  has_many :votes
  has_many :suggested_songs
  has_many :authorizations
  has_many :playlists, through: :authorizations

  validates :first_name, presence: true
  validates :last_name, presence: false
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: {with: VALID_EMAIL_REGEX}, :uniqueness => {:case_sensitive => false}
  validates :password, length: {in: 6..20}, confirmation: true, on: :create

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.email = auth.info.email
      user.password = SecureRandom.urlsafe_base64((20*3/4)).tr('lIO0', 'sxyz')
      user.uid = auth.uid
      user.first_name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      tempuser = TempUser.create(first_name: auth.info.name)
      user.tempuserid = tempuser.id
      user.save!
    end
  end

end
