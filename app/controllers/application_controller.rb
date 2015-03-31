class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def update_session
    session[:hide_keywords] = params[:hide_keywords] ? true : false

    respond_to do |format|
      format.json { render json: session }
    end
  end
end
