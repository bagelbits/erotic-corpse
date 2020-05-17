# frozen_string_literal: true

module HttpAuthConcern
  extend ActiveSupport::Concern
  included do
    before_action :http_authenticate
  end
  def http_authenticate
    return true unless %w[production test].include? Rails.env

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['ADMIN_USER'] && password == ENV['ADMIN_PASSWORD']
    end
  end
end
