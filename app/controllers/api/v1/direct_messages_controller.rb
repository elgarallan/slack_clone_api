class Api::V1::DirectMessagesController < Api::V1::BaseController
  before_action :set_direct_message, only: [ :update, :destroy ]
  before_action :authorize_user!, only: [ :update, :destroy ]

  def index
      messages = DirectMessage.where(sender: current_user).or(DirectMessage.where(receiver: current_user))

      render json: messages.as_json(
        only: [ :id, :sender_id, :receiver_id, :body, :created_at ],
        include: { sender: { only: [ :id, :username, :email ] } }
      ), status: :ok
  end

  def conversation
    user = User.find(params[:user_id])

    messages = DirectMessage.where(
      "(sender_id = :current AND receiver_id = :other) OR (sender_id = :other AND receiver_id = :current)",
      current: current_user.id, other: user.id
    ).order(:created_at)

    render json: messages.as_json(
      only: [ :id, :sender_id, :receiver_id, :body, :created_at ],
      include: { sender: { only: [ :id, :username, :email ] } }
    )
  end


  def create
    message = DirectMessage.new(direct_message_params)
    message.sender = current_user

    if message.save
      render json: message.as_json(
        only: [ :id, :sender_id, :receiver_id, :body, :created_at ],
        include: {
          sender: { only: [ :id, :username, :email ] }
        }
      ), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @direct_message.update(direct_message_params)
      render json: @direct_message.as_json(
        only: [ :id, :sender_id, :receiver_id, :body, :created_at ],
        include: {
          sender: { only: [ :id, :username, :email ] }
        }
      ), status: :ok
    else
      render json: { errors: @direct_message.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    @direct_message.destroy
    head :no_content
  end

  private

  def direct_message_params
    params.require(:direct_message).permit(:receiver_id, :body)
  end

  def set_direct_message
    @direct_message = DirectMessage.find_by(id: params[:id])
    render json: { error: "Message not found" }, status: :not_found unless @direct_message
  end


  def authorize_user!
    unless @direct_message.sender_id == current_user.id
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
