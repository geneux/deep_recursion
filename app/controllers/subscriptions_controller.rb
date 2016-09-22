class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_question

  respond_to :json

  def create
    authorize Question, :subscribe?
    respond_with @question.subscriptions.create(user: current_user), location: @question
  end

  def destroy
    @subscription = @question.subscriptions.find_by(user: current_user)
    authorize @question, :subscribe?
    respond_with @subscription.destroy, location: @question
  end

  private

  def load_question
    @question = Question.find(params[:id])
  end
end
