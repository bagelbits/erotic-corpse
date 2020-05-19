# frozen_string_literal: true

class DeliCounterController < ApplicationController
  def ticket
    ticket = Ticket.create

    if ticket == Ticket.now_serving
      puts 'We have a winner!'
      # TODO: Hook up ActionCable call here
      # TODO: Trigger called timeout job here
    end

    response = {
      ticket: ticket.id,
      token: ticket.token
    }
    render json: response
  end
end
