class WishlistsController < ApplicationController
  layout @@layout
  
  before_filter :require_admin, :only => [:index]
  before_filter :require_user
  
  before_filter :find_parent
  before_filter :find_wishlist, :only => [:edit, :update, :destroy]
  
  def index
    @root = LootTable.find_all_by_object_type('Zone', :include => :children)
    @zone = @boss = @root[0] # Set @zone so we know which bosses to not hide by default in the drop-down menu
    
    if params[:boss]
      @items = LootTable.find(:all, :include => [:parent, {:object => [{:wishlists => :member}, :item_stat] }], :conditions => ['parent_id = ?', params[:boss]])
      
      if @items.size > 0
        @boss  = @items[0].parent
        @zone  = @boss.parent
      end
    else
      @items = []
    end
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def new
    @wishlist = @parent.wishlists.new
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def edit
    respond_to do |wants|
      wants.html do
        if request.xhr?
          render :action => 'edit_inline'
        else
          render :action => 'edit'
        end
      end
    end
  end
  
  def create
    @wishlist = @parent.wishlists.new(params[:wishlist])
    
    respond_to do |wants|
      if @wishlist.save
        wants.html do
          flash[:success] = "Wishlist entry was successfully created."
          redirect_to(wishlists_path)
        end
        wants.js { render :partial => 'create', :object => @wishlist, :locals => { :success => true } }
      else
        wants.html { render :action => 'new' }
        wants.js { render :partial => 'create', :object => @wishlist, :locals => { :success => false } }
      end
    end
  end
  
  def update
    respond_to do |wants|
      if @wishlist.update_attributes(params[:wishlist])
        wants.html do
          flash[:success] = "Wishlist entry was successfully updated."
          redirect_to(wishlists_path)
        end
        wants.js { render :partial => 'update', :object => @wishlist, :locals => { :success => true } }
      else
        wants.html { render :action => "edit" }
        wants.js { render :partial => 'update', :object => @wishlist, :locals => { :success => false } }
      end
    end
  end
  
  def destroy
    @wishlist.destroy
    
    respond_to do |wants|
      wants.html do
        flash[:success] = "Wishlist entry was successfully deleted."
        redirect_to(wishlists_path)
      end
      wants.js do
        head interpret_status(:ok) # FIXME: Is this the right way to do this?
      end
    end
  end
  
  private
    def find_parent
      if params[:member_id]
        @parent = @member = Member.find(params[:member_id])
      end
    end
    
    def find_wishlist
      @wishlist = @member.wishlists.find(params[:id])
    end
end