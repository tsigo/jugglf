class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user,    :only => [:show, :edit, :update]
  before_filter :require_admin,   :only => :index
  
  before_filter :find_user, :only => [:show, :edit, :update]
  
  def index
    @users = User.find(:all, :order => 'login')
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def new
    @user = User.new
  end
  
  def show
    @user = @current_user
  end
  
  def edit
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:success] = 'Account registered!'
      redirect_back_or_default account_url
    else
      render :action => :new
    end
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = 'Account updated.'
      redirect_to account_url
    else
      render :action => :edit
    end
  end
  
  private
    def find_user
      @user = @current_user
    end
end