# frozen_string_literal: true

class DeliCounterController < ApplicationController
  def ticket
    ticket = Ticket.create

    TicketCalledTimeoutJob.set(wait: 10.seconds).perform_later(ticket.id) if ticket.id == Ticket.now_serving.id

    response = {
      ticket: ticket.id,
      token: ticket.token,
    }
    render json: response
  end

  def now_serving
    params.require(:ticket)
    params.require(:token)

    ticket = Ticket.now_serving
    return render json: {} unless ticket

    if ticket.checked_at < 10.seconds.ago
      TicketCalledTimeoutJob.perform_now(ticket.id)
      ticket = Ticket.now_serving
    end

    checking_ticket = Ticket.where(id: params[:ticket], token: params[:token]).first
    return render json: {} unless checking_ticket && checking_ticket.token == params[:token]

    checking_ticket.check_in!

    response = {
      ticket: ticket.id,
    }
    render json: response
  end

  def heartbeat
    params.require(:ticket)
    params.require(:token)

    ticket = Ticket.find(params[:ticket])
    return render json: { success: false } if ticket.closed? || ticket.token != params[:token]

    ticket.check_in!

    render json: { success: true }
  end
end
