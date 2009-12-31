class Attendance::LootController < ApplicationController
  before_filter :require_admin

  def edit
    @loots = LiveLoot.find(:all, :include => [:item, :member], :order => "id DESC")
    
    respond_to do |wants|
      wants.html
    end
  end
  
  def update
    @loots = LiveLoot.from_text(params[:live_loot][:input_text])
    
    # FIXME: This works, but if we fail to save the records, we destroy the user's input string.
    # Maybe store it in a session value and clear it once it works?
    LiveLoot.transaction do
      begin
        @loots.each(&:save!)
      rescue ActiveRecord::RecordInvalid => e
        # TODO: We need a detailed error message.
        flash[:error] = "At least one live loot record was invalid."
        raise ActiveRecord::Rollback
      ensure
        respond_to do |wants|
          wants.html { redirect_to edit_live_loot_path(1) } # TODO: What ID do we want to use?
          wants.js # FIXME: Rows are prepended regardless success or failure
        end
      end
    end
  end
end