class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :authenticate_user!

  add_flash_types :error

  def authorize_with_transaction!(ability)
    ActiveRecord::Base.transaction do
      object = yield
      authorize! ability, object
      object
    end
  end
end
