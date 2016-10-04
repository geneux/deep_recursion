require 'rails_helper'

describe AnswersController do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let!(:answer) { create(:answer, question: question, user: user) }
  let(:other_user) { create(:user) }
  let(:others_answer) { create(:answer, question: question, user: other_user) }

  let(:post_answer_attributes) { attributes_for(:answer) }
  let(:post_answer) { post :create, question_id: question.id, answer: post_answer_attributes, format: :js }
  let(:post_invalid_answer) { post :create, question_id: question.id, answer: attributes_for(:invalid_answer), format: :js }
  let(:patch_answer) { patch :update, id: answer, question_id: question, answer: attributes_for(:answer), format: :js }
  let(:destroy_answer) { delete :destroy, question_id: question, id: answer, format: :js }
  let(:patch_star_answer) { patch :star, id: answer, question_id: question, format: :js }

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      it 'stores new Answer in the database' do
        expect { post_answer }.to change(Answer, :count).by(1)
      end

      it 'associates new Answer with correct Question' do
        expect { post_answer }.to change(question.answers, :count).by(1)
      end

      it 'associates new Answer with correct User' do
        expect { post_answer }.to change(@user.answers, :count).by(1)
      end

      it 'renders #create template' do
        post_invalid_answer
        expect(response).to render_template :create
      end
    end

    context 'with invalid attributes' do
      it 'doesn\'t store the Answer' do
        expect { post_invalid_answer }.to_not change(Answer, :count)
      end

      it 'renders #create template' do
        post_invalid_answer
        expect(response).to render_template :create
      end
    end

    it_behaves_like :comet_publisher do
      let(:pub_channel) { "/questions/#{question.id}/answers" }
      let(:valid_request) { post_answer }
      let(:invalid_request) { post_invalid_answer }
      let(:valid_response_entry) { post_answer_attributes[:body] }
    end
  end

  describe 'PATCH #update' do
    before { sign_in user }

    context 'own answer' do
      it 'assigns answer to edit to @answer' do
        patch_answer
        answer.reload

        expect(assigns(:answer)).to eq answer
      end

      it 'answer assigned to @answer do belongs to correct question' do
        patch_answer
        answer.reload

        expect(assigns(:answer).question).to eq question
      end

      it 'changes answer attributes' do
        edited_body = Faker::Lorem.paragraph(4, true, 8)

        patch :update, id: answer, question_id: question, answer: {body: edited_body}, format: :js
        answer.reload

        expect(answer.body).to eq edited_body
      end

      it 'doesn\'t change user the answer belongs to' do
        @alt_user = create(:user)
        edited_body = Faker::Lorem.paragraph(4, true, 8)

        patch :update, id: answer, question_id: question, answer: {body: edited_body}, user: @alt_user, format: :js
        answer.reload

        expect(answer.user).not_to eq @alt_user
      end

      it 'renders #update partial' do
        patch_answer
        answer.reload
        expect(response).to render_template :update
      end
    end

    context 'other user\'s answer' do
      before { @alt_answer = create(:answer, question: question, user: create(:user)) }

      it 'doesn\'t change answer attributes' do
        edited_body = Faker::Lorem.paragraph(4, true, 8)
        patch :update, id: @alt_answer, question_id: question, answer: {body: edited_body}, format: :js
        @alt_answer.reload

        expect(@alt_answer.body).to eq @alt_answer.body
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in user }

    context 'own answer' do
      it 'deletes the answer' do
        answer.reload
        expect { destroy_answer }.to change(Answer, :count).by(-1)
      end

      it 'renders #destroy partial' do
        destroy_answer
        expect(response).to render_template :destroy
      end
    end

    context 'other user\'s answer' do
      before { @alt_answer = create(:answer, question: question, user: create(:user)) }

      it 'doesn\'t delete answer' do
        expect { delete :destroy, question_id: question, id: @alt_answer, format: :js }.
            to change(Answer, :count).by(0)
      end

      it 'keeps answer in DB' do
        delete :destroy, question_id: question, id: @alt_answer, format: :js
        expect(Answer.exists?(@alt_answer.id)).to be true
      end
    end
  end

  describe 'PATCH #star' do
    let(:answer) { create(:answer, question: question, user: user, starred: false) }
    before { sign_in user }

    it 'assigns answer to star to @answer' do
      patch_star_answer
      answer.reload

      expect(assigns(:answer)).to eq answer
    end

    context 'own question' do
      it 'sets star flag for selected answer' do
        patch_star_answer
        answer.reload

        expect(answer.starred).to eq true
      end

      it 'cleans star flag for previously starred answer' do
        starred_answer = create(:answer, question: question, user: user, starred: true)

        patch_star_answer
        answer.reload
        starred_answer.reload

        expect(starred_answer.starred).to eq false
      end

      it 'renders #star partial' do
        patch_star_answer
        expect(response).to render_template :star
      end
    end

    context 'other user\'s question' do
      before do
        alt_user = create(:user)
        alt_question = create(:question, user: alt_user)
        @alt_answer = create(:answer, question: alt_question, user: user, starred: false)
        @alt_starred_answer = create(:answer, question: alt_question, user: user, starred: true)
        patch :star, id: @alt_answer, question_id: alt_question, format: :js
      end

      it 'doesn\'t sets star flag for selected answer' do
        expect(@alt_answer.starred).to eq false
      end

      it 'keeps star flag for already starred answer' do
        expect(@alt_starred_answer.starred).to eq true
      end
    end
  end

  it_behaves_like :rated do
    let(:rateable) { answer }
    let(:others_rateable) { others_answer }

    let(:own_rating) { create(:answer_rating, user: user, rateable: answer) }
    let(:others_rating) { create(:answer_rating, user: other_user, rateable: others_answer) }
    let(:own_rating_others_rateable) { create(:answer_rating, user: user, rateable: others_answer) }

    let(:post_rate_inc) { post :rate_inc, id: others_answer, question_id: question, js: true }
    let(:post_rate_dec) { post :rate_dec, id: others_answer, question_id: question, js: true }
    let(:post_rate_revoke) { post :rate_revoke, id: others_answer, question_id: question, js: true }
  end
end
