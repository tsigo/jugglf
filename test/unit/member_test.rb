require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  fixtures :raids
  
  test "should not recache based on updated_at" do
    m = members(:tsigo)
    
    assert_equal(false, m.should_recache?)
  end
  
  test "should recache based on updated_at" do
    m = members(:sebudai)
    
    assert_equal(true, m.should_recache?)
  end
  
  test "should recache based on uncached_updates" do
    m = members(:tsigo)
    m.uncached_updates = 2
    
    assert_equal(true, m.should_recache?)
  end
  
  test "has raid attendance" do
    m = members(:tsigo)
    m.raids << raids(:today)
    m.raids << raids(:yesterday)
    
    assert_equal(2, m.attendance.count)
  end
  
  test "has item purchases" do
    m = members(:tsigo)
    assert_equal(0, m.items.count)
    
    i = Item.create(:name => 'Warglaive of Azzinoth', :price => 5.00)
    m.items << i
    
    assert_equal(1, m.items.count)
    assert_equal(m.id, i.buyer.id)
  end
  
  test "cache gets updated" do
    m = members(:update_cache)
    assert_equal(true, m.should_recache?)
    
    # Add raid attendance
    m.attendance << Attendee.create(:raid_id => raids(:today).id, :attendance => 1.00)
    m.attendance << Attendee.create(:raid_id => raids(:yesterday).id, :attendance => 1.00)
    # m.attendance << Attendee.create(:raid_id => raids(:two_months_ago).id, :attendance => 1.00)
    
    # Add an item
    m.items << Item.create(:name => 'Normal LF', :price => 5.00, 
      :raid_id => raids(:yesterday).id)
    m.items << Item.create(:name => 'Sit LF', :price => 30.00, 
      :raid_id => raids(:today).id, :situational => true)
    m.items << Item.create(:name => 'BiS LF, Not Affected', :price => 10.00, 
      :raid_id => raids(:two_months_ago).id, :best_in_slot => true)
    m.items << Item.create(:name => 'BiS LF', :price => 3.14, 
      :raid_id => raids(:yesterday).id, :best_in_slot => true)
    assert_equal(4, m.items.count)
    
    m.save!
    
    m = Member.find_by_name('UpdateMyCache')
    assert_equal(1.00, m.attendance_30)
    assert_equal(0.666667, m.attendance_90)
    
    assert_equal(5.00, m.lf)
    assert_equal(30.00, m.sitlf)
    assert_equal(3.14, m.bislf)
  end
end
