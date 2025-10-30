class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: %i[ edit update destroy ]
  before_action :set_teams, only: %i[ new edit create ] 

  def index
    @users = User
      .yield_self do |relation|
        params[:title].present? ? relation.where("name LIKE ?", "%#{params[:title]}%") : relation
      end
      .includes(:team)
  end

  def new
    @user_form = UserForm.new({})
  end

  def create
    @user_form = UserForm.new(user_params)
    
    respond_to do |format|
      if @user_form.save 
        @user = @user_form.user 
        format.html { redirect_to users_path, notice: "Create successful users." }
      else
        flash.now[:error] = @user_form.errors.full_messages.first
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @user_form = UserForm.new({}, @user)
  end

  def update
    @user_form = UserForm.new(user_params, @user)
    
    respond_to do |format|
      if @user_form.update
        format.html { redirect_to users_path, notice: "Updated successfully." }
      else
        flash.now[:error] = @user_form.errors.full_messages.first
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy!
    respond_to do |format|
      format.html { redirect_to users_path, notice: "User deleted successfully." }
      format.json { head :no_content }
    end
  end

  private

  def set_teams
    @teams = Team.all
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user_form).permit(:name, :password, :email, :avatar, :team_id)
  end
end
