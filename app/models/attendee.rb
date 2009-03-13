# == Schema Information
# Schema version: 20090312150316
#
# Table name: attendees
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  raid_id    :integer(4)
#  attendance :float
#

class Attendee < ActiveRecord::Base
  belongs_to :member, :counter_cache => :raids_count
  belongs_to :raid, :counter_cache => true
end
