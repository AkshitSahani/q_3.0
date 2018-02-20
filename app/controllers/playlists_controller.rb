class PlaylistsController < ApplicationController

  def player
    render :player, layout: false
  end

  def index
  end

  def show
    SuggestedSong.where(playlist_id: params[:id], status: "playing").update_all(status: "que")
    @access = Authorization.find_by(playlist_id: params[:id], user_id: session[:active_id])
    if @access
      @access = @access.status
    else
      @access = "Viewer"
    end

    @playlist_q = Playlist.find(params[:id])
    @host = User.find_by(tempuserid: @playlist_q.authorizations.find_by(status: 'Host').user_id)
    @playlist_q_songs = SuggestedSong.where(playlist_id: @playlist_q.id)
    @next_song_id = SuggestedSong.next_song_id(params[:id])
    @next_song_record = SuggestedSong.next_song_record(params[:id])
    @songs = SuggestedSong.playlist_songs(params[:id])

    # This is related to the search function we are showing

    response = HTTParty.get("https://connect.deezer.com/oauth/access_token.php?app_id=#{ENV["deezer_application_id"]}&secret=#{ENV["deezer_secret_key"]}&code=#{params[:code]}&output=json")
    access_token = response["access_token"]
    @albums = HTTParty.get("http://api.deezer.com/search/album?q=#{params[:search]}&#{access_token}")
    @tracks = HTTParty.get("http://api.deezer.com/search/track?q=#{params[:search]}&#{access_token}")
    @artists = HTTParty.get("http://api.deezer.com/search/artist?q=#{params[:search]}&#{access_token}")

    @unplayedsongs = SuggestedSong.where(playlist_id: @playlist_q.id, status: "played").order(status: :desc, net_vote: :desc)
    @playedsongs = SuggestedSong.where(playlist_id: @playlist_q.id, status: "played")

    # Local variables for gon
    songs =  SuggestedSong.playlist_songs(params[:id])
    votes = Vote.get_votes(params[:id])
    host_id = Authorization.where(playlist_id: params[:id], status: "Host")[0].user_id
    playlist = Playlist.find(params[:id])
    # Make them usable for javascript
    gon.data_for_request = [songs, '', host_id, votes, playlist, (session[:active_id] ? TempUser.find(session[:active_id]) : "")]
    render :layout => 'playlist'
  end

  def next_song
    @next_song_id = SuggestedSong.next_song_id(params[:id])
    @next_song_record = SuggestedSong.next_song_record(params[:id])
    respond_to do |format|
      format.json do render json: {song_id: @next_song_id, song_record: @next_song_record} end
    end
  end


  def update_song_playing
    SuggestedSong.find(params[:song_id]).update_attribute(:status, "playing")
  end


  def update_song
    SuggestedSong.find(params[:song_id]).update_attribute(:status, "played")
    songs = SuggestedSong.playlist_songs(params[:id])
    dup_songs = []
    songs.each do |song|
      dup_songs << song if song.status == "playing"
    end

    if dup_songs.count > 0 #when no songs are in playing status
      dup_songs.each do |song|
      SuggestedSong.find(song.id).update_attribute(:status, "que")
      end
    end

    @next_song_id = SuggestedSong.next_song_id(params[:id])
    @next_song_record = SuggestedSong.next_song_record(params[:id])

    SuggestedSong.find(@next_song_record).update_attribute(:status, "playing")
    render json: {song_id: @next_song_id, song_record: @next_song_record}
  end

  def playlist_broadcast
      @songs =  SuggestedSong.playlist_songs(params[:id])
      @votes = Vote.get_votes(params[:id])
      @host_id = Authorization.where(playlist_id: params[:id], status: "Host")[0].user_id
      @playlist = Playlist.find(params[:id])
      ActionCable.server.broadcast(:app, [@songs, '', @host_id, @votes, @playlist])
  end

  def join
    render :layout => "join"
  end

  def add_guest
    @access_code = params["access_code"]
    @playlist = Playlist.find_by(access_code: @access_code)
    if @playlist
      @authorization = Authorization.find_by(playlist_id: @playlist.id, user_id: session[:active_id])
      if @authorization
        redirect_to playlist_path(@playlist)
      elsif session[:user_id]
        Authorization.create(playlist_id: @playlist.id, user_id: session[:active_id], status: "Guest")
        redirect_to playlist_path(@playlist)
      else
        @user = TempUser.create();
        session[:user_type] = "temp"
        # XYZ Determine if line above is needed
        session[:active_id] = @user.id
        session[:playlist_id] = @playlist.id
        Authorization.create(playlist_id: @playlist.id, user_id: session[:active_id], status: "Guest")
        redirect_to temp_user_path
      end
    else
      render :join
    end
  end

  def name
  end

  def create_name
    @user = TempUser.find(session[:active_id])
    @user.update_attributes(name_params)
    redirect_to playlist_path(session[:playlist_id])
  end

  def new
    if !session[:user_id]
      redirect_to new_user_path
    else
      set_themes
      set_song_limit
      @playlist_q = Playlist.new
      render :layout => "create_playlist"
    end
  end

  def destroy
    @playlist_q = Playlist.find(params[:id])
    if @playlist_q.destroy
      redirect_to user_path(session[:user_id])
    end
  end

  def create
    set_themes
    set_song_limit
    access_code = Playlist.create_access_code
    if playlist_params[:song_limit] == "None"
      song_limit = 1000
    else
      song_limit = playlist_params[:song_limit]
    end

    case playlist_params[:theme]
    when 'Folk'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fcdn.pixabay.com%2Fphoto%2F2014%2F05%2F21%2F15%2F18%2Fmusician-349790_640.jpg'
    when 'Country'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fcdn.pixabay.com%2Fphoto%2F2014%2F05%2F21%2F15%2F18%2Fmusician-349790_640.jpg'
    when 'House/EDM'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1470225620780-dba8ba36b745%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D90569f2fc49891dfcf3de69f4321930f'
    when 'Electronic'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1470225620780-dba8ba36b745%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D90569f2fc49891dfcf3de69f4321930f'
    when 'Rock'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1485115369188-4bdca5e56b26%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D2d5dd058c8675aa7868f1f6f520da2b7'
    when 'Instrumental'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1445743432342-eac500ce72b7%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D0bd923f1a81e99a482b9a44d339eba11'
    when 'R&B'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1461783436728-0a9217714694%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3Dfbb40c0ee5e18f75cd35ae12d5d7288b'
    when 'Chill'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1471560090527-d1af5e4e6eb6%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D7ecf6c11e4900f3ede6aca96ccfae5d0'
    when 'Alternative'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1422034681339-7b5dbb46db18%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D612868dfdab7f353feedf528be37f3bf'
    when 'Indie'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1422034681339-7b5dbb46db18%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D612868dfdab7f353feedf528be37f3bf'
    when 'Rap'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1415886541506-6efc5e4b1786%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3Dc52f1e12b2cd220405cc3db305c9ab9e'
    when 'Hip-Hop'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1415886541506-6efc5e4b1786%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3Dc52f1e12b2cd220405cc3db305c9ab9e'
    when 'Jazz'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1484712548363-bad7b2ff3878%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D568508f274d090aeb841bc0b5eadecdd'
    when 'Blues'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1484712548363-bad7b2ff3878%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D568508f274d090aeb841bc0b5eadecdd'
    when 'Dance'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1482575832494-771f74bf6857%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D4d6bff93604128f856a49ab6d6b94a0e'
    when 'Party'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1482575832494-771f74bf6857%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D4d6bff93604128f856a49ab6d6b94a0e'
    when 'Pop'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1482575832494-771f74bf6857%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3D4d6bff93604128f856a49ab6d6b94a0e'
    when 'Other'
      album_image_url = 'https://slack-imgs.com/?c=1&url=https%3A%2F%2Fimages.unsplash.com%2Fphoto-1466253985008-19ae27987e03%3Fixlib%3Drb-0.3.5%26q%3D80%26fm%3Djpg%26crop%3Dentropy%26cs%3Dtinysrgb%26w%3D1080%26fit%3Dmax%26s%3Daf94cfd5015fe7d97db7ce8706cb0952'
    when 'Reggae'
      album_image_url = 'https://static.pexels.com/photos/59870/sunset-music-reggae-musician-59870.jpeg'
    end

    @playlist_q = Playlist.new(
      name: playlist_params[:name],
      description: playlist_params[:description],
      theme: playlist_params[:theme],
      access_code: access_code,
      song_limit: song_limit,
      album_art: album_image_url)

    if @playlist_q.save
      @authorization = Authorization.new(
        playlist_id: @playlist_q.id,
        user_id: session[:active_id],
        status: "Host")
    else
      flash.now[:alert] = @playlist_q.errors.full_messages
      render :new
    end

      if @authorization && @authorization.save
    redirect_to playlist_path(@playlist_q)
    end

  end

  def edit
    set_themes
    set_song_limit
    @playlist_q = Playlist.find(params[:id])
  end

  def update
    set_themes
    set_song_limit
    @playlist_q = Playlist.find(params[:id])
      if @playlist_q.update_attributes(playlist_params)
        redirect_to user_path(session[:user_id])
      else
        render :edit
      end
  end

  def update_publicity
    @playlist = Playlist.find(params[:id])
    if @playlist.public == false
      @playlist.update_attribute('public', true)
    elsif @playlist.public == true
      @playlist.update_attribute('public', false)
    end

    @host_id = Authorization.where(playlist_id: params[:id], status: "Host")[0].user_id

    @songs = SuggestedSong.playlist_songs(@playlist.id)

    # this is hacking
    status = []
    @songs.each do |song|
      status << song if song.status == "playing"
    end

    if status.count > 1
      song_to_adjust = status.last
      SuggestedSong.find(song_to_adjust.id).update_attribute(:status, "que")
    end

    @votes = Vote.get_votes(@playlist.id)
    ActionCable.server.broadcast(:app, [@playlist, '', @host_id])

    if @playlist.public == false
      ActionCable.server.broadcast(:app, [@songs, "", @host_id, @votes, @playlist])
    end

  end

  def guestlist
    guests = Authorization.where(playlist_id: params[:id], status: "Guest")
    forbiddens = Authorization.where(playlist_id: params[:id], status: "Forbidden")
    @guest_names = []
    guests.each do |guest|
      first_name = TempUser.find(guest.user_id).first_name
      user_id = guest.user_id
      status = guest.status
      g = [first_name, '', user_id, status]
      #XYZ Fix removed last name
      @guest_names << g
    end
    forbiddens.each do |forb|
      first_name = TempUser.find(forb.user_id).first_name
      user_id = forb.user_id
      status = forb.status
      f = [first_name, '', user_id, status]
      #XYZ Fix removed last name
      @guest_names << f
    end
      respond_to do |format|
        format.json do render json: @guest_names end
      end

  end

  def update_authorization

    guest_authorization = Authorization.find_by(playlist_id: params[:playlist_id], user_id: params[:user_id])
    if guest_authorization.status == "Guest"
      @authorization_update = guest_authorization.update_attribute(:status, "Forbidden")
    else
      @authorization_update = guest_authorization.update_attribute(:status, "Guest")
    end
  end

private

  def name_params
    params.permit(:first_name)
  end

  def playlist_params
      params.require(:playlist).permit(:name, :description, :theme, :song_limit)
  end

  def set_themes
    @themes = ['Pop', 'Alternative', 'Dance', 'Folk', 'Instrumental', 'Chill', 'Party', 'Blues', 'House/EDM', 'Rock', 'Rap', 'Hip-Hop', 'R&B', 'Electronic', 'Indie', 'Jazz', 'Reggae', 'Country', 'Other'].sort
  end

  def set_song_limit
    @song_limits = ['None', 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  end
end
