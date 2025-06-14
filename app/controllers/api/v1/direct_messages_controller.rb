class Api::V1::DirectMessagesController < Api::V1::BaseController
  def index
    messages = DirectMessage.where(sender: current_user).or(DirectMessage.where(receiver: current_user))
    render json: messages, status: :ok
  end

  def conversation
    user = User.find(params[:user_id])

    messages = DirectMessage.where(
      "(sender_id = :current AND receiver_id = :other) OR (sender_id = :other AND receiver_id = :current)",
      current: current_user.id, other: user.id
    ).order(:created_at)

    render json: messages
  end

  def create
    message = DirectMessage.new(direct_message_params)
    message.sender = current_user

    if message.save
      render json: message, status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def direct_message_params
    params.require(:direct_message).permit(:receiver_id, :body)
  end
end
