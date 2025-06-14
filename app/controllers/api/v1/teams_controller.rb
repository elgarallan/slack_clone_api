class Api::V1::TeamsController < Api::V1::BaseController
  before_action :set_team, only: [ :show, :update, :destroy ]

  # GET /api/v1/teams
  def index
    render json: current_user.teams
  end

  def available
    joined_team_ids = current_user.teams.pluck(:id)
    available_teams = Team.where.not(id: joined_team_ids)
    render json: available_teams.select(:id, :name)
  end

  # GET /api/v1/teams/:id
  def show
    team = Team.find(params[:id])

    render json: {
      id: team.id,
      name: team.name,
      members: team.users.select(:id, :username, :email),
      channels: team.channels.select(:id, :name)
    }
  end


  # POST /api/v1/teams
  def create
    team = Team.new(team_params)
    if team.save
      Membership.create!(user: current_user, team: team)
      render json: team, status: :created
    else
      render json: { errors: team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def join
    team = Team.find(params[:id])

    if team.users.include?(current_user)
      render json: { message: "Already a member of this team" }, status: :ok
    else
      Membership.create!(user: current_user, team: team)
      render json: { message: "Joined team successfully" }, status: :created
    end
  end

  def members
    team = current_user.teams.find(params[:id])
    render json: team.users.select(:id, :username, :email)
  end


  # PATCH/PUT /api/v1/teams/:id
  def update
    if @team.update(team_params)
      render json: @team
    else
      render json: { errors: @team.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/teams/:id
  def destroy
    @team.destroy
    head :no_content
  end

  private

  def set_team
    @team = Team.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Team not found" }, status: :not_found
  end

  def team_params
    params.require(:team).permit(:name)
  end
end
