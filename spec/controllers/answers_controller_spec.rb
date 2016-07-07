require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let!(:question) { create(:question, user: user) }

  describe 'POST #create' do
    sign_in_user

    context 'with valid attributes' do
      it 'stores new Answer in the database' do
        expect { post :create, question_id: question.id, answer: attributes_for(:answer), format: :js }.
            to change(Answer, :count).by(1)
      end

      it 'associates new Answer with correct Question' do
        expect { post :create, question_id: question.id, answer: attributes_for(:answer), format: :js }.
            to change(question.answers, :count).by(1)
      end

      it 'associates new Answer with correct User' do
        expect { post :create, question_id: question.id, answer: attributes_for(:answer), format: :js }.
            to change(@user.answers, :count).by(1)
      end

      it 'renders #create partial' do
        post :create, question_id: question.id, answer: attributes_for(:invalid_answer), format: :js
        expect(response).to render_template :create
      end

      # it 'shows :notice flash' do
      #   post :create, question_id: question.id, answer: attributes_for(:answer)
      #   expect(flash[:notice]).to be_present
      # end
    end

    context 'with invalid attributes' do
      it 'doesn\'t store the Answer' do
        expect { post :create, question_id: question.id, answer: attributes_for(:invalid_answer), format: :js }.
            to_not change(Answer, :count)
      end

      it 'renders to #create partial' do
        post :create, question_id: question.id, answer: attributes_for(:invalid_answer), format: :js
        expect(response).to render_template :create
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in user }

    context 'own answer' do
      let(:answer) { create(:answer, question: question, user: user) }

      it 'assigns answer to edit to @answer' do
        patch :update, id: answer, question_id: question, answer: attributes_for(:answer), format: :js
        answer.reload

        expect(assigns(:answer)).to eq answer
      end

      it 'answer assigned to @answer do belongs to correct question' do
        patch :update, id: answer, question_id: question, answer: attributes_for(:answer), format: :js
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
        patch :update, id: answer, question_id: question, answer: attributes_for(:answer), format: :js

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
    let(:answer) { create(:answer, question: question, user: user) }
    before { sign_in user }

    context 'own answer' do
      it 'deletes the answer' do
        answer.reload

        expect { delete :destroy, question_id: question, id: answer, format: :js }.
            to change(Answer, :count).by(-1)
      end

      it 'renders #destroy partial' do
        delete :destroy, question_id: question, id: answer, format: :js

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
      patch :star, id: answer, question_id: question, format: :js
      answer.reload

      expect(assigns(:answer)).to eq answer
    end

    context 'own question' do
      it 'sets star flag for selected answer' do
        patch :star, id: answer, question_id: question, format: :js
        answer.reload

        expect(answer.starred).to eq true
      end

      it 'cleans star flag for previously starred answer' do
        starred_answer = create(:answer, question: question, user: user, starred: true)

        patch :star, id: answer, question_id: question, format: :js
        answer.reload
        starred_answer.reload

        expect(starred_answer.starred).to eq false
      end

      it 'renders #star partial' do
        patch :star, id: answer, question_id: question, format: :js

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
end