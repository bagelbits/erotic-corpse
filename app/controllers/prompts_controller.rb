# frozen_string_literal: true

class PromptsController < ApplicationController
  def create
    params.require(:ticket)
    params.require(:token)
    params.require(:prompt)
    params.require(:previous_prompt_id)

    # TODO: Check ticket and token against now_serving
    # This requires everything else ActionCable and ActiveJob to
    # be setup.

    new_prompt = Prompt.create(prompt: params[:prompt])
    old_prompt = Prompt.find(params[:previous_prompt_id])
    old_prompt.next_prompt = new_prompt.id
    old_prompt.save!

    ticket = Ticket.find(params[:ticket])
    ticket.close!

    if Ticket.now_serving
      # TODO: Hookup ActionCable here
    end
    render json: new_prompt
  end

  def last
    params.require(:ticket)
    params.require(:token)

    # TODO: Check ticket and token against now_serving
    # This requires everything else ActionCable and ActiveJob to
    # be setup.
    next_prompt = Prompt.last_prompt
    ticket = Ticket.find(params[:ticket])
    ticket.got_response!
    # TODO: Trigger submit timeout job
    render json: next_prompt
  end

  def report
    params.require(:ticket)
    params.require(:token)

    # TODO: Check ticket and token against now_serving
    # This requires everything else ActionCable and ActiveJob to
    # be setup.

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
