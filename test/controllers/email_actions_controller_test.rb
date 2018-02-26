require 'test_helper'

class EmailActionsControllerTest < ActionDispatch::IntegrationTest
  test "should get confirm_email" do
    get email_actions_confirm_email_url
    assert_response :success
  end

end
