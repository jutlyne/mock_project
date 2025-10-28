class TeamsController < ApplicationController
  before_action :require_login
  before_action :set_team, only: %i[ edit update destroy ]

  def index
    @teams = Team
      .yield_self do |relation|
        params[:title].present? ? relation.where("name LIKE ?", "%#{params[:title]}%") : relation
      end
      .all
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to teams_path, notice: "Create successful teams." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @team.update(team_params)
      redirect_to teams_path, notice: "Updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy!

    respond_to do |format|
      format.html { redirect_to teams_path, notice: "Team deleted successfully." }
      format.json { head :no_content }
    end
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    permitted = params.require(:team).permit(:name)
    permitted
  end
end
