class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Send 'em back where they came from with a slap on the wrist
  def authority_forbidden(error)
    Authority.logger.warn(error.message)
    flash[:alert] = 'You are not authorized to complete that action.'
    redirect_to request.referrer.presence || root_path
  end

  protected

  def authenticate_user!(options = {})
    if user_signed_in?
      super
    else
      redirect_to '/users/sign_in'
    end
  end

  def after_sign_in_path_for(resource)
    user_path(resource)
  end

  alias_method :devise_current_user, :current_user

  def current_user
    UserPresenter.new(devise_current_user || User.null)
  end

end
