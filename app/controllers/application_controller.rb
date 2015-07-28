class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  add_flash_types :error

  def authorize_with_transaction!(ability)
    ActiveRecord::Base.transaction do
      object = yield
      authorize! ability, object
      object
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :given_name << :surname
    devise_parameter_sanitizer.for(:account_update) << :given_name << :surname
  end
end
