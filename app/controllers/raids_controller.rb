class RaidsController < ApplicationController
  layout @@layout
  
  before_filter :require_admin
  
  before_filter :find_raid, :only => [:show, :edit, :update, :destroy]
  
  def index
    @raids = Raid.paginate(:page => params[:page], :per_page => 40, :order => "date DESC")
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def show
    @attendees = @raid.attendees.find(:all, :include => :member, 
      :order => "#{Member.table_name}.wow_class, #{Member.table_name}.name")
    @drops     = @raid.loots.find(:all, :include => [:member, :item], :order => "#{Item.table_name}.name")
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def new
    @raid = Raid.new

    respond_to do |wants|
      wants.html
    end
  end
  
  def create
    @raid = Raid.new(params[:raid])
  
    respond_to do |wants|
      if @raid.save
        flash[:success] = 'Raid was successfully created.'
        wants.html { redirect_to(@raid) }
      else
        wants.html { render :action => "new" }
      end
    end
  end
  
  def destroy
    @raid.destroy
    
    flash[:success] = "Raid was successfully deleted."
    
    respond_to do |wants|
      wants.html { redirect_to(raids_path) }
    end
  end
  
  private
    def find_raid
      @raid = Raid.find(params[:id])
    end
end
