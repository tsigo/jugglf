require 'wishlist_data'

namespace :juggernaut do
  desc "Populate wishlist data"
  task :wishlist => [:environment] do
    [Boss, LootTable, Zone].each(&:destroy_all)

    WishlistData::Cataclysm::ThroneOfFourWinds
    WishlistData::Cataclysm::BastionOfTwilight
    WishlistData::Cataclysm::BlackwingDescent
    WishlistData::Cataclysm::Firelands
  end
end
