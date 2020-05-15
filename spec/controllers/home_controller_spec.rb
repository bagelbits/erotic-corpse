# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  it 'renders the homepage' do
    get :index
    expect(response.code).to eq('200')
  end
end
