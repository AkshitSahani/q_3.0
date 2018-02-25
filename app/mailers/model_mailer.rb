class ModelMailer < ApplicationMailer
  def user_email_vertification(user)
    @user = user
    email = mail subject: 'Confirm your email address'
  end
end
