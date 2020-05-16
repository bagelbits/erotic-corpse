class HomeController < ApplicationController
  def index
    render component: 'App'
  end
end
