require 'rails_helper'

describe QuestionsController do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:other_user) { create(:user) }
  let(:others_question) { create(:question, user: other_user) }

  let(:post_question_attributes) { attributes_for(:question) }
  let(:post_question) { post :create, question: post_question_attributes, format: :js }
  let(:post_invalid_question) { post :create, question: attributes_for(:invalid_question), format: :js }
  let(:patch_question) { patch :update, id: question, question: attributes_for(:question), format: :js }
  let(:destroy_question) { delete :destroy, id: question }

  describe 'GET #index' do
    let(:questions) { create_list(:question, 2) }

    before { get :index }

    it 'renders #index view' do
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    let(:answers) { create_list(:answer, 3, question: question) }

    context 'for unauthenticated user (authentication not needed)' do
      before { get :show, id: question }

      it 'assings the requested Question to @question' do
        expect(assigns(:question)).to eq question
      end

      it 'assigns new Answer for the Question' do
        expect(assigns(:answer)).to be_a_new(Answer)
      end

      it 'renders #show view' do
        expect(response).to render_template :show
      end
    end

    context 'for authenticated user' do
      sign_in_user
      let!(:new_subscription) { create(:subscription, user: @user, question: question) }

      it 'loads subscription' do
        get :show, id: question
        expect(assigns(:subscription)).to eq new_subscription
      end
    end
  end

  describe 'GET #new' do
    sign_in_user

    before { get :new }

    it 'assigns new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'renders #new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      it 'stores new Question in the database' do
        expect { post_question }.to change(Question, :count).by(1)
      end

      it 'associates new Question with correct User' do
        expect { post_question }.to change(@user.questions, :count).by(1)
      end

      it 'creates Subscription to the Question' do
        expect { post_question }.to change(Subscription, :count).by(1)
      end
    end

    context 'with invalid attributes' do
      it 'doesn\'t store the question' do
        expect { post_invalid_question }.to_not change(Question, :count)
      end

      it 'doesn\'t create Subscription to the Question' do
        expect { post_invalid_question }.to_not change(Subscription, :count)
      end
    end

    it 'renders #create template' do
      post_invalid_question
      expect(response).to render_template :create
    end

    it_behaves_like :comet_publisher do
      let(:pub_channel) { '/questions' }
      let(:valid_request) { post_question }
      let(:invalid_request) { post_invalid_question }
      let(:valid_response_entry) { post_question_attributes[:body] }
    end
  end

  describe 'PATCH #update' do
    before { sign_in user }

    context 'own Question' do
      it 'assigns question to edit to @question' do
        patch_question
        expect(assigns(:question)).to eq question
      end

      it 'Question assigned to @question do belongs to correct User' do
        patch_question
        expect(assigns(:question).user).to eq user
      end

      it 'changes Question attributes' do
        edited_question = create(:question, user: user)
        patch :update, id: question, question: {
            topic: edited_question.topic, body: edited_question.body}, format: :js
        question.reload
        expect(question.topic).to eq edited_question.topic
        expect(question.body).to eq edited_question.body
      end

      it 'doesn\'t change User the Question belongs to' do
        edited_question = create(:question, user: create(:user))
        patch :update, id: question, question: {
            topic: edited_question.topic, body: edited_question.body},
            user: edited_question.user, format: :js
        question.reload
        expect(question.user).not_to eq edited_question.user
      end

      it 'renders #update partial' do
        patch_question
        expect(response).to render_template :update
      end
    end

    context 'other user\'s Question' do
      before { @alt_question = create(:question, user: create(:user)) }

      it 'doesn\'t change Question attributes' do
        edited_question = create(:question, user: user)
        patch :update, id: @alt_question, question: {
            topic: edited_question.topic, body: edited_question.body}, format: :js
        @alt_question.reload
        expect(@alt_question.topic).to eq @alt_question.topic
        expect(@alt_question.body).to eq @alt_question.body
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in user }

    context 'own question' do
      it 'deletes question' do
        question
        expect { destroy_question }.to change(Question, :count).by(-1)
      end

      it 'redirects to index view' do
        destroy_question
        expect(response).to redirect_to questions_path
      end
    end

    context 'other User\'s Question' do
      before { @alt_question = create(:question, user: create(:user)) }

      it 'doesn\'t delete Question' do
        expect { delete :destroy, id: @alt_question }.to change(Question, :count).by(0)
      end

      it 'keeps Question in DB' do
        delete :destroy, id: @alt_question
        expect(Question.exists?(@alt_question.id)).to be true
      end

      subject { delete :destroy, id: @alt_question }
      it { is_expected.to redirect_to root_path }
      it('shows :alert flash') { is_expected { flash[:alert] }.to be_present }
    end
  end

  it_behaves_like :rated do
    let(:rateable) { question }
    let(:others_rateable) { others_question }

    let(:own_rating) { create(:question_rating, user: user, rateable: question) }
    let(:others_rating) { create(:question_rating, user: other_user, rateable: others_question) }
    let(:own_rating_others_rateable) { create(:question_rating, user: user, rateable: others_question) }

    let(:post_rate_inc) { post :rate_inc, id: others_question, format: :js }
    let(:post_rate_dec) { post :rate_dec, id: others_question, format: :js }
    let(:post_rate_revoke) { post :rate_revoke, id: others_question, format: :js }
  end
end
