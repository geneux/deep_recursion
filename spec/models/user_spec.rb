require 'rails_helper'

RSpec.describe User do
  it { is_expected.to have_many(:identities).dependent(:destroy) }
  it { is_expected.to have_many(:questions).dependent(:destroy) }
  it { is_expected.to have_many(:answers).dependent(:destroy) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }
  it { is_expected.to have_many(:subscriptions).dependent(:destroy) }

  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :password }

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '42') }

    context 'User\'s Identity already exists' do
      it 'returns valid user' do
        user.identities.create(provider: 'facebook', uid: '42')
        expect(User.find_for_oauth(auth)).to eq user
      end
    end

    context 'User\'s Identity doesn\'t exists' do
      context 'User elready exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '42',
            info: {email: user.email}) }

        it 'doesn\'t create new User' do
          expect { User.find_for_oauth(auth) }.to_not change(User, :count)
        end

        it 'creates Identity for the User' do
          expect { User.find_for_oauth(auth) }.to change(user.identities, :count).by(1)
        end

        it 'creates Identity with provider and uid' do
          identity = User.find_for_oauth(auth).identities.first

          expect(identity.provider).to eq auth.provider
          expect(identity.uid).to eq auth.uid
        end

        it 'returns User object' do
          expect(User.find_for_oauth(auth)).to eq user
        end
      end

      context 'User doesn\'t exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '42',
            info: {email: 'notexistent@user.com'}) }

        it 'creates new User' do
          expect { User.find_for_oauth(auth) }.to change(User, :count).by(1)
        end

        it 'returns new User' do
          expect(User.find_for_oauth(auth)).to be_a(User)
        end

        it 'fills User\'s email' do
          user = User.find_for_oauth(auth)
          expect(user.email).to eq auth.info.email
        end

        it 'creates Identity for the User' do
          user = User.find_for_oauth(auth)
          expect(user.identities).to_not be_empty
        end

        it 'creates Identity with provider and uid' do
          identity = User.find_for_oauth(auth).identities.first

          expect(identity.provider).to eq auth.provider
          expect(identity.uid).to eq auth.uid
        end
      end
    end
  end
end
