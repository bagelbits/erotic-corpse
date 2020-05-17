# frozen_string_literal: true

class AdminController < ApplicationController
  include HttpAuthConcern

  def index
    @story = Prompt.full_story
  end
end
