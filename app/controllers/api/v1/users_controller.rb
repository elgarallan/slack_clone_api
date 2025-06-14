module Api
  module V1
    class UsersController < ApplicationController
      def create
        user = User.new(user_params)
        if user.save
          token = JWT.encode({ user_id: user.id }, Rails.application.secret_key_base)
          render json: { token: token, user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :username, :password, :password_confirmation)
      end
    end
  end
end
