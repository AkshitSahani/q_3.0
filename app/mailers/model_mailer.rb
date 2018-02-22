class ModelMailer < ApplicationMailer
  def user_email_vertification
    @greeting = "ANDREW"
    email = mail subject: 'this is an email'
  end
end
