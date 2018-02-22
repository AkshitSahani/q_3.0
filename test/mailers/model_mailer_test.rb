require 'test_helper'

class ModelMailerTest < ActionMailer::TestCase
  test "user_email_vertification" do
    mail = ModelMailer.user_email_vertification
    assert_equal "User email vertification", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
