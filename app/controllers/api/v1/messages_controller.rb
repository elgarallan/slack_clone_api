class Api::V1::MessagesController < Api::V1::BaseController
  before_action :set_team_and_channel

  def index
    messages = @channel.messages.includes(:user).order(created_at: :asc)
    render json: messages.as_json(only: [ :id, :body, :created_at ], include: { user: { only: [ :id, :email ] } })
  end

  def create
    channel = Channel.find(params[:channel_id])
    message = channel.messages.build(message_params)
    message.user = current_user # assuming you're using JWT + current_user

    if message.save
      render json: message.as_json(include: { user: { only: [ :id, :username, :email ] } }), status: :created
    else
      render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_team_and_channel
    @team = current_user.teams.find_by(id: params[:team_id])
    @channel = @team&.channels&.find_by(id: params[:channel_id])
    render json: { error: "Channel not found" }, status: :not_found unless @channel
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
