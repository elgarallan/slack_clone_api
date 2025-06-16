class Api::V1::MembershipsController < Api::V1::BaseController
  def create
    team = current_user.teams.find_by(id: params[:team_id])
    user = User.find_by(email: params[:email])

    if team && user
      membership = Membership.find_or_create_by(user: user, team: team)
      render json: membership, status: :created
    else
      render json: { error: "Invalid team or user" }, status: :unprocessable_entity
    end
  end

  def index
    team = current_user.teams.find_by(id: params[:team_id])
    if team
      render json: team.users
    else
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end
end
