class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_question, only: [:show, :destroy]

  def index
    @questions = Question.all
  end

  def show
  end

  def new
    @question = Question.new
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user
    if @question.save
      redirect_to @question, notice: "Вопрос успешно задан."
    else
      render :new
    end
  end

  def destroy
    if @question.user == current_user
      @question.destroy!
      redirect_to questions_path, notice: "Вопрос успешно удален."
    else
      redirect_to @question, alert: "Нельзя удалить чужой вопрос."
    end
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:topic, :body)
  end
end
