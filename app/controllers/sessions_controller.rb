class SessionsController < ApplicationController

  def new
    if params[:q] == 'fb'
      redirect_to '/auth/facebook'
    else
      redirect_to '/auth/google_oauth2'
    end
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    if User.where(email:user.email).count > 1
      Transcation.where(receiver:user.email).last.destroy
      user.destroy
      redirect_to root_url, :alert => "User account with same email already exists"
      return
    end
    reset_session
    session[:user_id] = user.id
    redirect_to root_url, :notice => 'Signed in!'
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
