require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Item do
  fixtures :items
  
  before(:each) do
    @valid_attributes = {
    }
  end

  it "should create a new instance given valid attributes" do
    Item.create!(@valid_attributes)
  end
  
  it "should return the correct adjusted price" do
    items(:rot).adjusted_price.should == 0.50
    items(:best_in_slot).adjusted_price.should == items(:best_in_slot).price
  end
  
  it "should allow multiple items of the same name" do
    Item.destroy_all
    
    10.times do
      Item.create(:name => "Ubiquitous Item", :price => 3.14)
    end
    
    Item.all.count.should == 10
  end
  
  describe "from JuggyAttendance output" do
    before(:all) do
      @strings = {
        :single       => "Sebudai - [Arachnoid Gold Band]",
        :false_bis    => "Sebisudai - [Arachnoid Gold Band]",
        :best_in_slot => "Modrack (bis) - [Crown of the Lost Vanquisher]",
        :rot          => "Modrack (rot) - [Crown of the Lost Vanquisher]",
        :sit          => "Modrack (sit) - [Crown of the Lost Vanquisher]",
        :bisrot       => "Modrack (bis rot) - [Crown of the Lost Vanquisher]",
        :multiple     => "Modrack (bis), Rosoo (bis) - [Crown of the Lost Vanquisher]"
      }
    end
    
    before(:each) do
      Item.destroy_all
      Member.destroy_all
    end
    
    it "should not automatically insert items" do
      items = Item.from_attendance_output(@strings[:single])
      
      Item.count.should == 0
    end
    
    it "should correctly set best_in_slot" do
      items = Item.from_attendance_output(@strings[:best_in_slot])
      items[0].best_in_slot?.should be_true
    end
    
    it "should correctly set rot" do
      items = Item.from_attendance_output(@strings[:rot])
      items[0].rot?.should be_true
    end
    
    it "should correctly set situational" do
      items = Item.from_attendance_output(@strings[:sit])
      items[0].situational?.should be_true
    end
    
    it "should correctly set best_in_slot and rot" do
      items = Item.from_attendance_output(@strings[:bisrot])

      items[0].adjusted_price.should == 0.50
      items[0].best_in_slot?.should be_true
      items[0].situational?.should_not be_true
    end
    
    it "should not have false positives for purchase types inside buyer names" do
      items = Item.from_attendance_output(@strings[:false_bis])
      
      items[0].rot?.should_not be_true
      items[0].best_in_slot?.should_not be_true
      items[0].situational?.should_not be_true
    end
    
    it "should populate single item from single line" do
      items = Item.from_attendance_output(@strings[:single])
      items.length.should == 1
    end
    
    it "should populate multiple items from single line" do
      items = Item.from_attendance_output(@strings[:multiple])
      items.length.should == 2
    end
    
    it "should populate multiple items from multiple lines" do
      output = %Q{Sebudai - [Arachnoid Gold Band]
      Scipion - [Chains of Adoration]
      Elanar (rot), Alephone (sit) - [Shadow of the Ghoul]
      Scipion (bis) - [Totem of Misery]
      Scipion - [Wraith Strike]
      Horky (bis) - [Dying Curse]
      Parawon (sit) - [Thrusting Bands]
      Scipion (sit) - [Angry Dread]
      Parawon - [Belt of Potent Chanting]
      Scipion (sit) - [Fool's Trial]
      Tsigo (sit) - [Haunting Call]
      Sebudai (sit) - [Leggings of Colossal Strides]
      Parawon (sit) - [Cloak of the Shadowed Sun]
      Sebudai (rot) - [The Hand of Nerub]
      Elanar (bis) - [Mantle of the Lost Protector]
      Tsigo (rot) - [Mantle of the Lost Conqueror]
      Darkkfall - [Shoulderguards of the Undaunted]
      Darkkfall (bis) - [Split Greathammer]
      Zelus (bis) - [Gemmed Wand of the Nerubians]
      Mithal (bis) - [Breastplate of the Lost Conqueror]
      Tsigo (sit) - [Spire of Sunset]
      Alephone (bis) - [Legplates of the Lost Conqueror]
      Sweetmeat (bis) - [Strong-Handed Ring]
      Darkkfall (bis) - [Bracers of Unrelenting Attack]
      Thorona (bis) - [Gothik's Cowl]
      Sebudai - [Aged Winter Cloak]
      Elanar (sit) - [Armageddon]
      Alephone (sit) - [Breastplate of the Lost Conqueror]
      Bemoan (bis) - [Heroic Key to the Focusing Iris]
      Alephone (bis) - [Soul of the Dead]
      Katarzyna (bis) - [Betrayer of Humanity]
      Sebudai (rot) - [Journey's End]
      Scipion (sit) - [Voice of Reason]
      Modrack (bis), Rosoo (bis) - [Crown of the Lost Vanquisher]
      }
      
      output.each do |line|
        unless line.strip!.empty?
          items = Item.from_attendance_output(line)
        
          items.each do |item|
            item.save!
          end
        end
      end

      Item.count.should == 36
      Member.find_by_name('Tsigo').items.size.should == 3
    end
  end
  
  describe "automatic pricing" do
    fixtures :members
    
    it "should calculate Torch of Holy Fire (Main Hand) price for Hunters" do
      i = Item.create(:name => 'Torch of Holy Fire', :member => members(:sebudai))
      i.determine_item_price.should == 1.25
    end
    
    it "should calculate Torch of Holy Fire (Main Hand) price for non-Hunters" do
      i = Item.create(:name => 'Torch of Holy Fire', :member => members(:tsigo))
      i.determine_item_price.should == 4.00
    end
  end
end