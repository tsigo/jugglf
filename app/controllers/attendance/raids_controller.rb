class Attendance::RaidsController < ApplicationController
  before_filter :require_admin
  
  before_filter :find_raid, :only => [:show, :start]
  
  def index
    @raids = LiveRaid.find(:all, :order => 'id DESC')
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def show
    respond_to do |wants|
      wants.html
    end
  end
  
  def new
    @live_raid = LiveRaid.new
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def create
    @live_raid = LiveRaid.new(params[:live_raid])
    
    respond_to do |wants|
      if @live_raid.save
        wants.html { redirect_to live_raid_path(@live_raid) }
      else
        wants.html { render :action => :new }
      end
    end
  end
  
  def start
    @live_raid.start!
    
    respond_to do |wants|
      wants.html { redirect_to live_raid_path(@live_raid) }
    end
  end
  
  private
    def find_raid
      @live_raid = LiveRaid.find(params[:id])
    end
end