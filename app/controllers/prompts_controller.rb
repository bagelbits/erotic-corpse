# frozen_string_literal: true

class PromptsController < ApplicationController
  def index
    prompts = Prompt.all
    render json: prompts
  end

  def create
    params.require(:prompt)
    params.require(:previous_prompt_id)
    new_prompt = Prompt.create(prompt: params[:prompt])
    old_prompt = Prompt.find(params[:previous_prompt_id])
    old_prompt.next_prompt = new_prompt.id
    old_prompt.save!
    render json: new_prompt
  end

  def last
    next_prompt = Prompt.last_prompt
    render json: next_prompt
  end

  def report
    prompt = Prompt.find(params[:id])
    prompt.report!
    response = {
      success: true,
      error: ''
    }
    render json: response
  rescue ActiveRecord::RecordInvalid
    response = {
      success: false,
      error: "Unfortunately, we can't roll back the story anymore. Sorry for the inconvience."
    }
    render json: response
  end
end
