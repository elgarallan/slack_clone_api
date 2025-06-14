class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user

  private

  def authenticate_user
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last

    if token.blank?
      return render json: { error: "Missing token" }, status: :unauthorized
    end

    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      @current_user = User.find(decoded["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end
