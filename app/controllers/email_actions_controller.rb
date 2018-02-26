class EmailActionsController < ApplicationController
  def confirm_email
    user = User.find(params[:user_id])
    if user.confirm_code == params[:confirm_code]
      user.update_attributes(:email_confirmed => true, :confirm_code => nil)
      flash[:notice] = "Email confirmed"
    else
      flash[:alert] = "Confirmation link is incorrect"
    end
    redirect_to user_path(params[:user_id])
  end
end
