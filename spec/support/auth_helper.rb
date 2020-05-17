# frozen_string_literal: true

module AuthHelper
  def http_login
    user = ENV['ADMIN_USER']
    pw = ENV['ADMIN_PASSWORD']
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end

  def bad_http_login
    user = 'bad_user'
    pw = 'bad_password'
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pw)
  end
end
