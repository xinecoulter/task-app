class IdentitiesController < ApplicationController
  def destroy
    identity = Identity.find(params[:id])
    authorize! :destroy, identity
    identity.destroy!
    flash[:notice] = "Successfully removed social media account."
    redirect_to edit_user_registration_path
  end
end
