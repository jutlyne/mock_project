class SessionsController < ApplicationController
  layout "unauth_application"

  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
    @login_form = LoginForm.new
  end

  def create
    @login_form = LoginForm.new(login_form_params)
    if @login_form.valid?
      user = User.find_by(email: @login_form.email.downcase)
      
      if user&.authenticate(@login_form.password)
        session[:user_id] = user.id
        redirect_to users_path, notice: "Logged in successfully!"
      else
        flash.now[:alert] = "Invalid email or password."
        render :new
      end
    else
      flash.now[:error] = @login_form.errors.full_messages.first
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "Logged out successfully."
  end

  # Reset password logic
  def reset_password_form
  end

  def send_reset_password
    email_to_use = params[:email].present? ? params[:email] : session[:reset_email]

    if email_to_use.blank?
      redirect_to reset_password_form_path, alert: "Your session has expired. Please re-enter your email." and return
    end

    @user = User.find_by(email: email_to_use)

    if @user
      pin = @user.generate_and_save_reset_pin
      @user.send_password_reset_email(pin)
      
      session[:reset_email] = @user.email 

      redirect_to verify_password_reset_path, notice: "A verification code has been sent to your email. Please check your inbox."
    else
      flash.now[:alert] = "Email address not found."
      render :reset_password_form
    end
  end

  def verify
  end

  def check
    @user = User.find_by(email: session[:reset_email])

    if @user && @user.password_reset_pin.to_s == params[:pin]
      if @user.pin_expired?
        flash.now[:alert] = "Verification code has expired. Please request a new one."
        render :verify
      else
        session[:pin_verified] = true
        @user.update_columns(password_reset_pin: nil)
        redirect_to edit_password_reset_path
      end
    else
      flash.now[:alert] = "Invalid verification code."
      render :verify
    end
  end

  def edit
    unless session[:pin_verified] && session[:reset_email].present?
      redirect_to new_password_reset_path, alert: "You must verify the PIN before resetting your password."
    end
    @user = User.find_by(email: session[:reset_email])
  end

  def update
    @user = User.find_by(email: session[:reset_email])
    
    unless session[:pin_verified] && @user
      redirect_to new_password_reset_path, alert: "Invalid password reset session." and return
    end
    
    if @user.update(user_params)
      session[:reset_email] = nil
      session[:pin_verified] = nil
      session[:user_id] = @user.id
      redirect_to users_path, notice: "Password has been reset successfully!"
    else
      render :edit
    end
  end

  private

  def redirect_if_logged_in
    if current_user
      redirect_to request.referer || users_path, notice: "You are already logged in."
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def login_form_params
    params.require(:login_form).permit(:email, :password)
  end
end
