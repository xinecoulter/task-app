class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    identity = current_user.add_identity(request.env["omniauth.auth"])
    if identity.persisted?
      flash[:notice] = "Awesomesauce! #{identity.name.titleize} account linked."
    else
      flash[:error] = "Womp, womp. Something went wrong."
    end
    redirect_to edit_user_registration_path
  end

  alias_method :facebook, :all
end
