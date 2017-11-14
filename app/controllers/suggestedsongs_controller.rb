class SuggestedsongsController < ApplicationController
  def new
    @suggested_song = SuggestedSong.new
  end

 def create
   @host_id = Authorization.where(playlist_id: params[:playlist_id], status: "Host")[0].user_id
   @votes = Vote.get_votes(params[:playlist_id])
   @playlist = Playlist.find(params[:playlist_id])

   access = Authorization.find_by(playlist_id: params[:playlist_id], user_id: session[:active_id]).status
   guest_song_count = SuggestedSong.where(playlist_id: params[:playlist_id], user_id: session[:active_id]).count
   playlist_limit = Playlist.find(params[:playlist_id]).song_limit

   if access == "Guest"

     if guest_song_count < playlist_limit

      @songs_before = SuggestedSong.playlist_songs(params[:playlist_id])

      if @songs_before.where(status: "played").length == @songs_before.length
          @suggested_song = SuggestedSong.new(song_id: params[:song_id], user_id: session[:active_id], user_name: TempUser.find(session[:active_id]).first_name, playlist_id: params[:playlist_id], name: params[:name], artist: params[:artist], status: "que")
         if SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id]).count > 0 &&
          (SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id])).last.status != "played"
          render json: {message: "Track is already Q'd up", status: false}
         else
          @suggested_song.save
          render json: {message: "Song added!", status: true}
          @songs = SuggestedSong.playlist_songs(params[:playlist_id])
        ActionCable.server.broadcast(:app, [@songs, "restart", @host_id, @votes, @playlist])
        end

      else

        @suggested_song = SuggestedSong.new(song_id: params[:song_id], user_id: session[:active_id], user_name: TempUser.find(session[:active_id]).first_name, playlist_id: params[:playlist_id], name: params[:name], artist: params[:artist], status: "que")

        if SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id]).count > 0 &&
          (SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id])).last.status != "played"
          render json: {message: "Track is already Q'd up", status: false}
         else
          @suggested_song.save
          render json: {message: "Song added!", status: true}
          @songs = SuggestedSong.playlist_songs(params[:playlist_id])
          ActionCable.server.broadcast(:app, [@songs, '', @host_id, @votes, @playlist])
         end


      end

     else
      render json: {message: "You've reached your maximum number of song adds!"}

     end

 else

   @songs_before = SuggestedSong.playlist_songs(params[:playlist_id])

   if @songs_before.where(status: "played").length == @songs_before.length
       @suggested_song = SuggestedSong.new(song_id: params[:song_id], user_id: session[:active_id], user_name: TempUser.find(session[:active_id]).first_name, playlist_id: params[:playlist_id], name: params[:name], artist: params[:artist], status: "que")
      if SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id]).count > 0 &&
       (SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id])).last.status != "played"
       render json: {message: "Track is already Q'd up", status: false}
      else
       @suggested_song.save
       render json: {message: "Song added!", status: true}
       @songs = SuggestedSong.playlist_songs(params[:playlist_id])
       ActionCable.server.broadcast(:app, [@songs, "restart", @host_id, @votes, @playlist])
     end

   else

     @suggested_song = SuggestedSong.new(song_id: params[:song_id], user_id: session[:active_id], user_name: TempUser.find(session[:active_id]).first_name, playlist_id: params[:playlist_id], name: params[:name], artist: params[:artist], status: "que")

     if SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id]).count > 0 &&
       (SuggestedSong.where(playlist_id: params[:playlist_id], song_id: params[:song_id])).last.status != "played"
       render json: {message: "Track is already Q'd up", status: false}
      else
       @suggested_song.save
       render json: {message: "Song added!", status: true}
       @songs = SuggestedSong.playlist_songs(params[:playlist_id])
       ActionCable.server.broadcast(:app, [@songs, '', @host_id, @votes, @playlist])
      end
   end

 end

 end

 def get_album
    response = HTTParty.get("https://connect.deezer.com/oauth/access_token.php?app_id=#{ENV["deezer_application_id"]}&secret=#{ENV["deezer_secret_key"]}&code=&output=json")
    access_token = response["access_token"]
    @album_results = HTTParty.get("http://api.deezer.com/album/#{params[:album]}")

   if request.xhr?
     respond_to do |format|
       format.json do render json: {albums:  @album_results} end
     end
   end

 end

 def get_artist
   response = HTTParty.get("https://connect.deezer.com/oauth/access_token.php?app_id=#{ENV["deezer_application_id"]}&secret=#{ENV["deezer_secret_key"]}&code=&output=json")
   access_token = response["access_token"]
   @artist_results = HTTParty.get("https://api.deezer.com/artist/#{params[:artist]}/top?limit=25/")

   if request.xhr?
     respond_to do |format|
       format.json do render json: {artists:  @artist_results} end
     end
   end

 end

  def index
    @playlist_q = Playlist.find(params[:playlist_id])

    response = HTTParty.get("https://connect.deezer.com/oauth/access_token.php?app_id=#{ENV["deezer_application_id"]}&secret=#{ENV["deezer_secret_key"]}&code=&output=json")
    access_token = response["access_token"]
    @albums = HTTParty.get("http://api.deezer.com/search/album?q=#{params[:q]}&#{access_token}")
    @tracks = HTTParty.get("http://api.deezer.com/search/track?q=#{params[:q]}&#{access_token}")
    @artists = HTTParty.get("http://api.deezer.com/search/artist?q=#{params[:q]}&#{access_token}")

    if request.xhr?
      respond_to do |format|
        format.json do render json: {artists:  @artists, albums: @albums, tracks: @tracks} end
      end
    end

  end

 def show
   @suggested_song = SuggestedSong.find(params[:id])
 end

 def destroy
    @host_id = Authorization.where(playlist_id: params[:playlist_id], status: "Host")[0].user_id
    @playlist_q = Playlist.find(params[:playlist_id])
    @suggested_song = SuggestedSong.find_by(playlist_id: @playlist_q.id, id: params[:id])
    @suggested_song.destroy
    @votes = Vote.get_votes(params[:playlist_id])
    @songs = SuggestedSong.playlist_songs(params[:playlist_id])
    ActionCable.server.broadcast(:app, [@songs,'', @host_id, @votes, @playlist_q])

  end

end
