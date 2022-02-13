# frozen_string_literal: true

require 'rails_helper'
require 'support/auth_helper'

RSpec.describe AdminController do
  render_views
  include AuthHelper

  describe 'index' do
    context 'with correct user/pass' do
      before do
        http_login
      end

      let(:third_prompt) { build(:prompt, prompt: 'This is a test 3') }
      let(:second_prompt) do
        build(:prompt, prompt: 'This is a test 2', next_prompt: third_prompt.id)
      end
      let(:first_prompt) do
        build(:prompt, prompt: 'This is a test 1', next_prompt: second_prompt.id)
      end

      let(:full_story) do
        [
          { prompt: first_prompt.prompt, reported: first_prompt.reported },
          { prompt: second_prompt.prompt, reported: second_prompt.reported },
          { prompt: third_prompt.prompt, reported: third_prompt.reported },
        ]
      end

      it 'renders' do
        allow(Prompt).to receive(:full_story).and_return(full_story)
        expect(Prompt).to receive(:full_story)
        get :index
        expect(response.code).to eq('200')
      end
    end

    context 'with incorrect user/pass' do
      before do
        bad_http_login
      end

      it 'fails' do
        get :index
        expect(response.code).to eq('401')
        expect(response.body).to eq("HTTP Basic: Access denied.\n")
      end
    end
  end
end
