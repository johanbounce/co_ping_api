# frozen_string_literal: true

RSpec.describe 'GET /pings/:id', type: :request do
  let(:user) { create(:user, role: 'user', community_status: 'accepted') }
  let(:user_credentials) { user.create_new_auth_token }
  let(:user_headers) do
    { HTTP_ACCEPT: 'application/json' }.merge!(user_credentials)
  end

  describe 'Can see pongs that belongs to their ping' do
    let!(:ping) { create(:ping, user_id: user.id) }
    let!(:pong2) { create(:pong, ping_id: ping.id, active: true, status: 'accepted') }
    let!(:pong3) { create(:pong, ping_id: ping.id, active: true, status: 'accepted') }

    before { get "/pings/#{user.id}", headers: user_headers }

    it 'returns a 200 response status' do
      expect(response).to have_http_status 200
    end

    it 'returns ping with active pongs' do
      expect(response_json['ping']['id']).to eq ping.id
    end

    it 'returns ping with active pongs' do
      expect(response_json['ping']['pongs'].count).to eq 2
    end

    it 'return name of pong owner' do
      expect(response_json['ping']['pongs'].first['user_name']).to eq 'Betty'
    end
  end

  describe 'user get message that there is no pongs' do
    let!(:ping) { create(:ping, user_id: user.id) }

    before { get "/pings/#{user.id}", headers: user_headers }

    it 'returns message' do
      expect(response_json['message']).to eq 'Your shopping bag looks light!'
    end
  end

  describe 'user has no ping' do
    before { get "/pings/#{user.id}", headers: user_headers }

    it 'returns message' do
      expect(response_json['message']).to eq 'It seems like you have not planned to go shopping yet'
    end
  end
end
