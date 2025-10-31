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
    @team_form = TeamForm.new({})
  end

  def create
    @team_form = TeamForm.new(team_params)

    respond_to do |format|
      if @team_form.save
        format.html { redirect_to teams_path, notice: "Create successful teams." }
      else
        flash.now[:error] = @team_form.errors.full_messages.first
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @team_form = TeamForm.new({}, @team)
  end

  def update
    @team_form = TeamForm.new(team_params, @team)

    respond_to do |format|
      if @team_form.update
        format.html { redirect_to teams_path, notice: "Updated successfully." }
      else
        flash.now[:error] = @team_form.errors.full_messages.first
        format.html { render :edit, status: :unprocessable_entity }
      end
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
    params.require(:team_form).permit(:name)
  end
end
