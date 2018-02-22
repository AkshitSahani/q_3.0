# Preview all emails at http://localhost:3000/rails/mailers/model_mailer
class ModelMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/model_mailer/user_email_vertification
  def user_email_vertification
    ModelMailer.user_email_vertification
  end

end
