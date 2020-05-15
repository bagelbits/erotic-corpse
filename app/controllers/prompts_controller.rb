# frozen_string_literal: true

class PromptsController < ApplicationController
  def index
    prompts = Prompt.all
    render json: prompts
  end

  def create
    new_prompt = Prompt.new(prompt: params[:prompt]).save!
    old_prompt = Prompt.find(params[:previous_prompt_id])
    old_prompt.next_prompt = new_prompt.id
    old_prompt.save!
    render json: new_prompt
  end

  def last
    next_prompt = Prompt.where(next_prompt: nil, reported: false).last
    render json: next_prompt
  end

  def report
    prompt = Prompt.find(params[:prompt_id])
    prompt.report!
  end
end
