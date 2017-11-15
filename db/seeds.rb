# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Playlist.destroy_all
SuggestedSong.destroy_all
Authorization.destroy_all


tempuserid = TempUser.create(first_name: "Bitmaker").id
User.create!(
  first_name: "Bitmaker",
  last_name: "Labs",
  email: "bit@maker.com",
  password: "password",
  password_confirmation: "password",
  tempuserid: tempuserid,
)

9.times do
  first_name = Faker::Name.first_name
  tempuser = TempUser.create(first_name: first_name)
  User.create!(
    first_name: first_name,
    last_name: Faker::Name.last_name,
    email: Faker::Internet.free_email,
    password: 'password',
    password_confirmation: 'password',
    tempuserid: tempuser.id,
  )
end

Playlist.create!(
  name: "Views From The 6",
  description: "Drake's Mixtape",
  theme: "Hip-Hop",
  access_code: Playlist.create_access_code,
  song_limit: 1000,
  public: true,
  album_art: 'https://i1.wp.com/hypebeast.com/image/2016/04/drake-views-digital-booklet-4.jpg?quality=95&w=1755',
)

drake_songs = [124659382, 134711916, 124659390, 107926978, 95258826, 101308856, 124659398, 95258830, 70562483, 124659368]

drake_songs.each do |song|
  s = SuggestedSong.selected_song(song)
  SuggestedSong.create!(
    song_id: s[0],
    playlist_id: 1,
    user_id: 1,
    name: s[2],
    net_vote: rand(1..10),
    artist: s[1],
    user_name: Faker::Name.first_name,
    status: 'que',
  )
end

Playlist.create!(
  name: "The New Escobar",
  description: "Q The Kanye",
  theme: "Hip-Hop",
  access_code: Playlist.create_access_code,
  song_limit: 1000,
  public: true,
  album_art: 'https://static.pexels.com/photos/59870/sunset-music-reggae-musician-59870.jpeg',
)

kanye_songs = [17605156, 17606676, 130483478,
127162941, 127162929, 127162921, 127162909, 17599495, 130483482, 93519236]

kanye_songs.each do |song|
  s = SuggestedSong.selected_song(song)
  SuggestedSong.create!(
    song_id: s[0],
    playlist_id: 2,
    user_id: 1,
    name: s[2],
    net_vote: rand(1..10),
    artist: s[1],
    user_name: Faker::Name.first_name,
    status: 'que',
  )
end

Playlist.create!(
  name: "Tomorrowland: Toronto",
  description: "Digital Dreaming",
  theme: "House/EDM",
  access_code: Playlist.create_access_code,
  song_limit: 1000,
  public: true,
  album_art: 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1470225620780-dba8ba36b745%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D90569f2fc49891dfcf3de69f4321930f',
)

electronic_music = [142415429, 65720750, 142778890, 60904574, 139936597, 140295627, 100551922, 73919323, 80223674, 134033198]

electronic_music.each do |song|
  s = SuggestedSong.selected_song(song)
  SuggestedSong.create!(
    song_id: s[0],
    playlist_id: 3,
    user_id: 1,
    name: s[2],
    net_vote: rand(1..10),
    artist: s[1],
    user_name: Faker::Name.first_name,
    status: 'que',
  )
end

Playlist.create!(
  name: "Wayhome",
  description: "Bringing home the hits",
  theme: "Indie",
  access_code: Playlist.create_access_code,
  song_limit: 1000,
  public: true,
  album_art: 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1422034681339-7b5dbb46db18%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D612868dfdab7f353feedf528be37f3bf',
)

stephen_jam = [136887772, 78129603, 15546831, 133931994, 142240637, 137819053, 49532111, 114395812, 121258078,
  141939667, 117253034, 129860350, 140295501, 99417868]

stephen_jam.each do |song|
  s = SuggestedSong.selected_song(song)
  SuggestedSong.create!(
    song_id: s[0],
    playlist_id: 4,
    user_id: 1,
    name: s[2],
    net_vote: rand(1..10),
    artist: s[1],
    user_name: Faker::Name.first_name,
    status: 'que',
  )
end

counter = 0
4.times do
  counter += 1
  Authorization.create!(
  playlist_id: counter,
  user_id: 1,
  status: "Host",
  )
end

20.times do
  Authorization.create!(
  playlist_id: rand(1..4),
  user_id: rand(2..10),
  status: "Guest",
  )
end
