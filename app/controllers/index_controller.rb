class IndexController < ApplicationController
  layout @@layout
  
  def index
    @counts = Member.active.count(:group => 'wow_class')
    
    @attendance_guild = Member.active.find(:first,
      :select => 'AVG(attendance_30) AS avg_30, AVG(attendance_90) AS avg_90, AVG(attendance_lifetime) AS avg_lifetime')
    @attendance = Member.active.find(:all, :order => 'wow_class', :group => 'wow_class', 
      :select => 'wow_class, AVG(attendance_30) AS avg_30, AVG(attendance_90) AS avg_90, AVG(attendance_lifetime) AS avg_lifetime')
      
    @lootfactor_guild = Member.active.find(:first,
      :select => 'AVG(lf) AS avg_lf, AVG(sitlf) AS avg_sitlf, AVG(bislf) AS avg_bislf')
    @lootfactor =   Member.active.find(:all, :order => 'wow_class', :group => 'wow_class', 
      :select => 'wow_class, AVG(lf) AS avg_lf, AVG(sitlf) AS avg_sitlf, AVG(bislf) AS avg_bislf')
    
    respond_to do |wants|
      wants.html
    end
  end
end
