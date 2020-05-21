# frozen_string_literal: true

class PromptsController < ApplicationController
  def create
    params.require(:ticket)
    params.require(:token)
    params.require(:prompt)
    params.require(:previous_prompt_id)

    ticket = Ticket.find(params[:ticket])
    if ticket != Ticket.now_serving || ticket.token != params[:token]
      return render json: {}
    end

    new_prompt = Prompt.create(prompt: params[:prompt])
    old_prompt = Prompt.find(params[:previous_prompt_id])
    old_prompt.next_prompt = new_prompt.id
    old_prompt.save!

    ticket.close!

    render json: new_prompt
  end

  def last
    params.require(:ticket)
    params.require(:token)

    ticket = Ticket.find(params[:ticket])
    if ticket != Ticket.now_serving || ticket.token != params[:token]
      return render json: {}
    end

    ticket.got_response!
    ticket.check_in!
    TicketSubmitTimeoutJob.set(wait: 3.minutes).perform_later(ticket.id)

    render json: Prompt.last_prompt
  end

  def report
    params.require(:ticket)
    params.require(:token)

    ticket = Ticket.find(params[:ticket])
    if ticket != Ticket.now_serving || ticket.token != params[:token]
      return render json: {
        success: false,
        error: "Unfortunately, you shouldn't have that ticket"
      }
    end

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
