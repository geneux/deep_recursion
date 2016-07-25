class QuestionsController < ApplicationController
  include Rated

  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_question, only: [:show, :destroy]

  def index
    @questions = Question.all
    @question = Question.new
    @question.attachments.build
  end

  def show
    @answer = @question.answers.build
    @answer.attachments.build
  end

  def new
    @question = Question.new
    @question.attachments.build
  end

  def create
    @question = Question.new(question_params)
    @question.user_id = current_user.id
    # if @question.save
    #   PrivatePub.publish_to '/questions', question: @question
    #   redirect_to @question, notice: 'Question asked.'
    # else
    #   render :new
    # end
    @question.save
    PrivatePub.publish_to '/questions', question: @question
    render :nothing
    
  end

  def update
    @question = Question.find(params[:id])
    @question.update(question_params)
  end

  def destroy
    if @question.user_id == current_user.id
      @question.destroy!
      redirect_to questions_path, notice: 'Question deleted.'
    else
      redirect_to @question, alert: 'Cannot delete other user\'s question.'
    end
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:topic, :body,
                                     attachments_attributes: [:id, :file, :_destroy])
  end
end
