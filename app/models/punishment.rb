# == Schema Information
#
# Table name: punishments
#
#  id         :integer(4)      not null, primary key
#  member_id  :integer(4)
#  reason     :string(255)
#  expires    :date
#  value      :float           default(0.0)
#  created_at :datetime
#  updated_at :datetime
#

class Punishment < ActiveRecord::Base
  # Relationships -------------------------------------------------------------
  belongs_to :member
  
  # Attributes ----------------------------------------------------------------
  attr_accessible :reason, :expires, :expires_string, :value
  
  def expires_string
    # Default to 56 days from now so that it acts as a normal loot item
    ( self.expires.nil? ) ? 52.days.from_now.to_date : self.expires.to_date
  end
  def expires_string=(value)
    self.expires = Time.parse(value)
  end
  
  # Validations ---------------------------------------------------------------
  validates_presence_of :reason
  validates_presence_of :value
  validates_presence_of :expires
  validates_numericality_of :value
  
  # Callbacks -----------------------------------------------------------------
  after_save    :update_member_cache
  after_destroy :update_member_cache
  
  # Class Methods -------------------------------------------------------------
  named_scope :active, :conditions => ['expires > ?', Date.today]
  
  # Instance Methods ----------------------------------------------------------
  
  def expire!
    self.expires = 24.hours.until(Date.today)
    self.save!
  end
  
  private
    def update_member_cache
      self.member.update_cache unless self.member.nil?
    end
end
