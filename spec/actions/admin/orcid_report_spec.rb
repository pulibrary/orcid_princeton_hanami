# frozen_string_literal: true

RSpec.describe OrcidPrinceton::Actions::Admin::OrcidReport do
  let(:params) { {} }

  context 'entra login is enabled' do
    before do
      allow(Hanami.app.settings).to receive(:use_entra).and_return(true)
    end

    it 'works' do
      response = subject.call(params)
      expect(response).to be_redirect
      expect(response.location).to eq '/auth/entra_id'
    end
  end

  context 'entra login is disabled' do
    before do
      allow(Hanami.app.settings).to receive(:use_entra).and_return(false)
    end

    it 'works' do
      response = subject.call(params)
      expect(response).to be_redirect
      expect(response.location).to eq '/auth/cas'
    end
  end

  context 'a user is logged in' do
    let(:user) { Factory[:user] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager)] }

    it 'redirects to root' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_redirect
      expect(response.flash.next[:notice]).to eq('You are not authorized')
    end
  end

  context 'an admin user is logged' do
    let(:user) { Factory[:admin] }
    let(:warden_manager) { Warden::Manager.new(nil) }
    let(:params) { Hash['warden' => Warden::Proxy.new({}, warden_manager)] }

    it 'shows the logged in user info' do
      params['warden'].set_user user.uid
      response = subject.call(params)
      expect(response).to be_successful
      expect(response.headers['Content-Type']).to eq('text/csv; charset=utf-8')
      expect(response.body.count).to eq(1)
      expect { CSV.parse(response.body.first) }.not_to raise_error
    end

    context 'when the PeopleSoft report operation fails' do
      let(:people_soft_report) do
        instance_double(OrcidPrinceton::Operations::PeopleSoftReport).tap do |report|
          allow(report).to receive(:call)
            .and_return(Dry::Monads::Result::Failure.new('could not write report'))
        end
      end
      subject { described_class.new(people_soft_report:) }

      it 'returns an empty body' do
        params['warden'].set_user user.uid
        response = subject.call(params)
        expect(response.body).to eq([''])
      end
    end
  end
end
