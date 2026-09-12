# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController do
  # Server rendering moved into the view, which controller specs stub out by default.
  render_views

  it 'renders the homepage' do
    get :index

    expect(response.code).to eq('200')
  end

  it 'server renders the App component into the page' do
    get :index

    expect(response.body).to include('js-react-on-rails-component')
    expect(response.body).to include('Welcome to Erotic Corpse')
  end
end
