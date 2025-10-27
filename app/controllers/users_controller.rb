class UsersController < ApplicationController
  before_action :require_login
  before_action :set_user, only: %i[ edit update destroy ]

  def index
    @users = User.all 
  end

  def new
    @user = User.new
    @teams = Team.all
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: "Create successful users." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @teams = Team.all
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: "Updated successfully."
    else
      render :edit, status: :unprocessable_entity
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

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted = params.require(:user).permit(:name, :password, :email, :avatar)
    if permitted[:password].blank?
      permitted.delete(:password)
    end
    
    if permitted[:avatar].blank?
      permitted.delete(:avatar)
    end
    
    permitted
  end
end
