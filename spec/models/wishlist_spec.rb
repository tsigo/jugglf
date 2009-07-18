# == Schema Information
# Schema version: 20090717234345
#
# Table name: wishlists
#
#  id         :integer(4)      not null, primary key
#  item_id    :integer(4)
#  member_id  :integer(4)
#  priority   :string(255)     default("normal"), not null
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Wishlist do
  before(:each) do
    @wishlist = Wishlist.make
  end
  it "should be valid" do
    @wishlist.should be_valid
  end
  
  it "should not allow invalid priority types" do
    @wishlist.priority = 'invalid'
    lambda { @wishlist.save! }.should raise_error
  end
  
  it "should not allow nil items" do
    @wishlist.item_id = nil
    lambda { @wishlist.save! }.should raise_error
  end
  
  describe "#item_name" do
    before(:each) do
      Item.destroy_all
    end
    
    it "should return the name of the item" do
      @wishlist.item = Item.make(:name => 'NewItem')
      @wishlist.item_name.should == 'NewItem'
    end
    
    it "should find the name of the existing item when assigned" do
      item = Item.make(:name => 'ExistingItem')
      @wishlist.item_name = 'ExistingItem'
      @wishlist.item_id.should == item.id
    end
    
    it "should create the item if no item was found" do
      lambda { @wishlist.item_name = 'NewItem' }.should change(Item, :count).by(1)
    end
    
    it "should allow the note to be parsed from the item name" do
      @wishlist.note = ''
      @wishlist.item_name = "ItemName [Note via item name]"
      @wishlist.note.should == 'Note via item name'
    end
    
    # it "should not let note in params overwrite note in name" do
    #   wishlist = Wishlist.make(:item_name => 'Name [Note]', :note => 'Also Note')
    #   wishlist.note.should_not == 'Also Note'
    # end
    
    it "should not set the item note via item_name if a note already exists" do
      @wishlist.item_name = "ItemName [Note via item name]"
      @wishlist.note.should == "I really want this item!"
    end
  end
end
