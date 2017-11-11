class SessionsController < ApplicationController
  layout "login"

  def new
  end

  def destroy
  end

  def frontpage
    @public_playlists = []
    @public_playlists << Playlist.find(1)
    @public_playlists << Playlist.find(2)
    @public_playlists << Playlist.find(3)
    @public_playlists << Playlist.find(4)
    render :layout => 'alternative'
  end

  def create
    if params[:email]
      user = User.find_by(email: params[:email])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        session[:actve_id] = user.tempuserid
        redirect_to user_path(user.id)
      else
        flash.now[:alert] = "Invalid email or password!"
        render "new"
      end
    elsif env["omniauth.auth"]
      auth = env["omniauth.auth"]
      if User.find_by_email(auth.info.email)
        user = User.find_by_email(auth.info.email)
        user.update_attributes(user_params_fb(auth))
        session[:user_id] = user.id
        session[:active_id] = user.tempuserid
      else
        user = User.from_omniauth(auth)
        session[:active_id] = user.tempuserid
        session[:user_id] = user.id
      end
      redirect_to user_path(user.id)
    else
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

  def view
    @playlist_q = Playlist.find(params[:id])
    @songs = SuggestedSong.playlist_songs(@playlist_q.id)
    @songs.each do |song|
      song.update_attribute(:status, "que")
    end
  end

  private
  def user_params_fb(auth)
    params = ActionController::Parameters.new({
      facebook: {
        provider: auth.provider,
        uid: auth.uid,
        oauth_token: auth.credentials.token,
        oauth_expires_at: Time.at(auth.credentials.expires_at)
      }
    })
    params.require(:facebook).permit(:provider, :uid, :oauth_token, :oauth_expires_at)
  end

end
