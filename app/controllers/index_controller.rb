class IndexController < ApplicationController
  def index
    cache_defaults = {:controller => 'index', :action => 'index'}

    # Number of members in guild, number in each class
    unless fragment_exist?(cache_defaults.merge(:action_suffix => 'class_counts'))
      @count_guild = Member.active.count
      @counts      = IndexStat.class_counts(:active)
    end

    # Attendance averages
    unless fragment_exist?(cache_defaults.merge(:action_suffix => 'attendance_averages'))
      @attendance_guild = IndexStat.attendance_average(:guild)
      @attendance       = IndexStat.attendance_average(:class)
    end

    unless fragment_exist?(cache_defaults.merge(:action_suffix => 'loot_factor_averages'))
      @lootfactor_guild = IndexStat.loot_factor_average(:guild)
      @lootfactor       = IndexStat.loot_factor_average(:class)
    end

    @stat_groups = []
    ['common_items', 'common_tokens', 'most_requested', 'loots_per_raid', 'oldest_members', 'best_attendance', 'least_recruitable', 'highest_turnover', 'shadowmourne_progress'].each do |key|
      unless fragment_exist?(cache_defaults.merge(:action_suffix => key))
        # Fragment doesn't exist, call the matching IndexStat method and pass it on to the view
        @stat_groups << [key, IndexStat.send(key)] 
      else
        # Fragment already exists, just add the key to array so that the partial still gets rendered
        @stat_groups << [key, nil]
      end
    end

    respond_to do |wants|
      wants.html
    end
  end
end
