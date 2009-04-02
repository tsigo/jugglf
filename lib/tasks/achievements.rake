namespace :jugg do
  desc "Update achievement cache"
  task :achievements => [:environment] do
    Member.active.each do |member|
      puts "Processing #{member.name}"
      CompletedAchievement.parse_member(member)
    end
    
    # Surely there's a better way to do this, but whatever.
    FileUtils.rm_rf(Dir['tmp/cache/views/*/achievements*'])
  end
end