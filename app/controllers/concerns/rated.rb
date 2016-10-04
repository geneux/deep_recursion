module Rated
  extend ActiveSupport::Concern
  included do
    before_action :find_rateable, only: [:rate_inc, :rate_dec, :rate_revoke]
  end

  def rate_inc
    authorize @rateable, :rate?
    @rateable.rate_up!(current_user)
    render json: json_data(false)
  end

  def rate_dec
    authorize @rateable, :rate?
    @rateable.rate_down!(current_user)
    render json: json_data(false)
  end

  def rate_revoke
    authorize @rateable, :rate?
    return head :forbidden unless current_user? || own_rate_exists?
    @rateable.revoke_rate!(current_user)
    render json: json_data(true)
  end

  private

  def json_data(revoked)
    {id: @rateable.id, rating: @rateable.rating, revoked: revoked}
  end

  def current_user?
    @rateable.user_id == current_user.id
  end

  def own_rate_exists?
    Rating.exists?(rateable: @rateable, user_id: current_user.id)
  end

  def find_rateable
    @rateable = controller_name.classify.constantize.find(params[:id])
  end
end
