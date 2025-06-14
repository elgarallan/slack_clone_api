class Api::V1::ChannelsController < Api::V1::BaseController
  before_action :set_team
  before_action :set_channel, only: [ :show, :update, :destroy ]

  def index
    render json: @team.channels
  end

  def show
    render json: @channel
  end

  def create
    channel = @team.channels.new(channel_params)
    if channel.save
      render json: channel, status: :created
    else
      render json: { errors: channel.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def join
    channel = Channel.find(params[:id])

    if channel.private? && !channel.team.users.include?(current_user)
      render json: { error: "Join the team first" }, status: :forbidden
    elsif channel.users.include?(current_user)
      render json: { message: "Already in channel" }, status: :ok
    else
      channel.users << current_user
      render json: { message: "Joined channel successfully" }, status: :created
    end
  end

  def update
    if @channel.update(channel_params)
      render json: @channel
    else
      render json: { errors: @channel.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @channel.destroy
    head :no_content
  end

  private

  def set_team
    @team = current_user.teams.find_by(id: params[:team_id])
    render json: { error: "Team not found" }, status: :not_found unless @team
  end

  def set_channel
    @channel = @team.channels.find_by(id: params[:id] || params[:channel_id])
    render json: { error: "Channel not found" }, status: :not_found unless @channel
  end

  def channel_params
    params.require(:channel).permit(:name)
  end
end
