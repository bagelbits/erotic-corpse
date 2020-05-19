# frozen_string_literal: true

class DeliCounterController < ApplicationController
  def ticket
    ticket = Ticket.create

    if ticket == Ticket.now_serving
      puts 'We have a winner!'
      # TODO: Trigger called timeout job here
    end

    response = {
      ticket: ticket.id,
      token: ticket.token
    }
    render json: response
  end

  def now_serving
    params.require(:ticket)
    params.require(:token)

    ticket = Ticket.now_serving

    checking_ticket = Ticket.where(id: params[:ticket], token: params[:token]).first
    return render json: {} unless checking_ticket

    checking_ticket.checked_at = Time.now
    checking_ticket.save!

    response = {
      ticket: ticket.id
    }
    render json: response
  end
end
