# I have no idea why this has to be here, but whatever. It seems to work.
class ItemPrice
end

module Juggy
  require 'singleton'
  
  class ItemPrice
    include Singleton
    MIN_LEVEL = 226
    
    def initialize
      @values = {
        'LEVELS' => ['226', '239', '245', '258', '264', '277'], # NOTE: Not 272, this array is only used for weapons.
        
        'Head' => nil, 'Chest' => nil, 'Legs' => {
          '226' => 0.50,
          '239' => 1.00,
          '245' => 1.50,
          '258' => 2.00,
          '264' => 2.50,
          '277' => 3.00
        },
        'Shoulder' => nil, 'Shoulders' => nil, 'Hands' => nil, 'Feet' => {
          '226' => 0.00,
          '239' => 0.50,
          '245' => 1.00,
          '258' => 1.50,
          '264' => 2.00,
          '277' => 2.50
        },
        'Wrist' => nil, 'Waist' => nil, 'Finger' => {
          '226' => 0.00,
          '239' => 0.00,
          '245' => 0.50,
          '258' => 1.00,
          '264' => 1.50,
          '277' => 2.00
        },
        'Neck' => nil, 'Back' => {
          '226' => 0.00,
          '239' => 0.00,
          '245' => 0.50,
          '258' => 1.00,
          '264' => 1.50,
          '272' => 2.00, # Special case for Tribute Chest, grumble.
          '277' => 2.50
        },
        'Two-Hand' => {
          '226' => [0.00, 0.00],
          '232' => [1.00, 0.00],
          '239' => [2.00, 0.50],
          '245' => [3.00, 1.00],
          '258' => [4.00, 1.50],
          '264' => [5.00, 2.00],
          '277' => [6.00, 2.50],
        },
        
        # Healer/Caster
        'Main Hand' => {
          '226' => 1.00,
          '232' => 1.50,
          '239' => 2.00,
          '245' => 2.50,
          '258' => 3.00,
          '264' => 3.50,
          '277' => 4.00
        },
        'Shield' => nil, 'Held In Off-hand' => {
          '226' => 0.00,
          '232' => 0.00,
          '239' => 0.00,
          '245' => 0.50,
          '258' => 1.00,
          '264' => 1.50,
          '277' => 2.00
        },
        # Melee DPS/Hunter
        'One-Hand' => nil, 'Off Hand' => nil, 'Melee DPS Weapon' => {
          '226' => [0.00, 0.00],
          '232' => [0.50, 0.00],
          '239' => [1.00, 0.00],
          '245' => [1.50, 0.50],
          '258' => [2.00, 0.75],
          '264' => [2.50, 1.00],
          '277' => [3.00, 1.25]
        },
        
        'Relic' => nil, 'Idol' => nil, 'Totem' => nil, 'Thrown' => nil, 'Sigil' => nil, 'Ranged' => {
          '226' => [0.00, 0.00],
          '232' => [0.00, 0.00],
          '239' => [0.00, 1.00],
          '245' => [0.00, 2.00],
          '258' => [0.50, 3.00],
          '264' => [1.00, 4.00],
          '277' => [1.50, 5.00]
        },
        'Trinket' => {
          # Patch 3.1
          "Blood of the Old God"              => 0.00,
          "Comet's Trail"                     => 1.00,
          "Flare of the Heavens"              => 1.00,
          "Heart of Iron"                     => 0.00,
          "Living Flame"                      => 0.00,
          "Pandora's Plea"                    => 0.00,
          "Scale of Fates"                    => 0.00,
          "Show of Faith"                     => 1.00,
          "The General's Heart"               => 0.00,
          "Vanquished Clutches of Yogg-Saron" => 0.00,
          "Wrathstone"                        => 0.00,
          
          # Patch 3.2 [245 price, 258 price]
          "Death's Choice"        => [1.00, 2.00],
          "Juggernaut's Vitality" => [1.00, 2.00],
          "Reign of the Dead"     => [1.00, 2.00],
          "Solace of the Fallen"  => [1.00, 2.00],
          
          # Patch 3.3 [264 price, 277 price]
          "Althor's Abacus"          => [2.00, 4.00],
          "Corpse Tongue Coin"       => [2.00, 4.00],
          "Deathbringer's Will"      => [2.00, 4.00],
          "Dislodged Foreign Object" => [2.00, 4.00],
          "Unidentifiable Organ"     => [2.00, 4.00],
        }
      }

      @values['Head'] = @values['Chest'] = @values['Legs']
      @values['Shoulder'] = @values['Shoulders'] = @values['Hands'] = @values['Feet']
      @values['Wrist'] = @values['Waist'] = @values['Finger']
      @values['Neck'] = @values['Back']
      @values['Shield'] = @values['Held In Off-hand']
      @values['One-Hand'] = @values['Off Hand'] = @values['Melee DPS Weapon']
      @values['Relic'] = @values['Idol'] = @values['Totem'] = @values['Thrown'] = @values['Sigil'] = @values['Ranged']
      
      @special_weapon_slots = ['Main Hand', 'Held In Off-hand', 'One-Hand', 'Off Hand', 'Shield']
    end

    def price(options = {})
      options[:id]     ||= nil
      options[:name]   ||= nil
      options[:item]   ||= options[:name] # Item name
      options[:slot]   ||= nil            # Item slot
      options[:level]  ||= 0              # Item level (ilvl)
      options[:class]  ||= nil            # Buyer WoW class; special cases for weapons

      options[:level] = options[:level].to_i
      
      # Damn special items
      return 0.00 if options[:item] == "Fragment of Val'anyr"
      
      if not options[:level] or options[:level] < MIN_LEVEL or not options[:slot]
        options = special_case_options(options)
        
        # Still lower than our min level, which means it's an older item, just make it 0.00
        return 0.00 if options[:level] < MIN_LEVEL
      end
      
      return if options[:level] < MIN_LEVEL or options[:slot] == nil
      
      value = nil
      
      if options[:slot] == 'Trinket'
        value = trinket_value(options)
      elsif @special_weapon_slots.include?(options[:slot])
        value = special_weapon_value(options)
      else
        value = default_value(options)
      end

      value
    end

    private
      def default_value(options)
        return if @values[options[:slot]].nil?
        
        value = nil
        slotval = @values[options[:slot]]
        slotval.sort.each do |level,values|
          if level.to_i <= options[:level]
            if values.is_a? Float
              value = values
            else
              value = (options[:class] == 'Hunter') ? values[1] : values[0]
            end
          end
        end
        
        value
      end
      
      # Determines the price for Weapons that ARE NOT Two-Handers and ARE NOT Ranged
      # based on conditions such as buyer class and slot.
      def special_weapon_value(options)
        return if options[:class].nil?

        # Figure out the price on a per-class special case basis
        value = nil
        if ['Druid', 'Mage', 'Paladin', 'Priest', 'Warlock'].include? options[:class]
          # These classes have no special cases, use the defaults
          value = default_value(options)
        else
          # Find out what item level group we're dealing with
          price_group = nil
          slotval = @values['LEVELS']
          slotval.sort.each do |level|
            if level.to_i <= options[:level]
              price_group = level.to_s
            end
          end

          if options[:class] == 'Death Knight'
            value = @values['Melee DPS Weapon'][price_group][0]
          elsif options[:class] == 'Hunter'
            # Price everything as a Melee DPS weapon with the Hunter price
            value = @values['Melee DPS Weapon'][price_group][1]
          elsif options[:class] == 'Rogue'
            value = @values['Melee DPS Weapon'][price_group][0]
          elsif options[:class] == 'Shaman'
            if options[:slot] == 'Shield'
              # Shields are only used by Resto/Ele Shaman, it's a normal Shield price
              value = @values['Shield'][price_group]
            elsif options[:slot] == 'One-Hand'
              # We're gonna guess that a non-Enhancement Shaman would never use a One-Hand weapon
              value = @values['Melee DPS Weapon'][price_group][0]
            else
              value = default_value(options)
            end
          elsif options[:class] == 'Warrior'
            # Price everything as a Melee DPS weapon, even Shields
            value = @values['Melee DPS Weapon'][price_group][0]
          end
        end

        value
      end
      
      def trinket_value(options)
        value = nil
        
        if @values['Trinket'][options[:item]]
          value = @values['Trinket'][options[:item]]
          
          # 3.2 Trinkets share names with their lower-level counterparts
          if value.is_a? Array
            value = ( options[:level] == 245 ) ? value[0] : value[1]
          end
        else
          # raise "Invalid Trinket: #{options[:item]}"
        end

        value
      end

      def special_case_options(options)
        if options[:item] == 'Heroic Key to the Focusing Iris'
          options[:slot]  = 'Neck'
          options[:level] = 226

        elsif options[:item] == 'Reply-Code Alpha'
          # This stupid item can actually be a Ring or a Cloak. Price it as a Ring by default
          options[:slot]  = 'Finger'
          options[:level] = 239

        elsif options[:level] == 80
          if options[:item] =~ /^Regalia of the Grand (Conqueror|Protector|Vanquisher)$/
            # Tier 9 258 Token
            options[:slot] = 'Chest' # Not always, but it has the correct price point we want for all Regalia
            options[:level] = 258

          elsif options[:item] == 'Trophy of the Crusade'
            # Tier 9 245 Token
            options[:slot] = 'Chest' # Not always, but it has the correct price point we want for all Trophies
            options[:level] = 245

          elsif [52028, 52029, 52030].include? options[:id]
            # Tier 10 277 Token
            options[:slot] = 'Chest' # Not always, but it has the correct price point we want for all Marks
            options[:level] = 277

          elsif [52025, 52026, 52027].include? options[:id]
            # Tier 10 266 Token
            options[:slot] = 'Chest' # Not always, but it has the correct price point we want for all Marks
            options[:level] = 266

          else
            # Tier 8 or Tier 7 token
            matches = options[:item].match(/^(.+) of the (Lost|Wayward) (Conqueror|Protector|Vanquisher)$/)
            if matches and matches.length > 0
              options[:slot] = determine_token_slot(matches[1])
              options[:level] = determine_token_level(matches[1], matches[2])
            end
          end
        end

        options
      end
      
      def determine_token_slot(name)
        name = name.strip.downcase
        
        if name == 'breastplate' or name == 'chestguard'
          return 'Chest'
        elsif name == 'crown' or name == 'helm'
          return 'Head'
        elsif name == 'gauntlets' or name == 'gloves'
          return 'Hands'
        elsif name == 'legplates' or name == 'leggings'
          return 'Legs'
        elsif name == 'mantle' or name == 'spaulders'
          return 'Shoulders'
        end
      end
      
      def determine_token_level(piece, group)
        piece = piece.strip.downcase
        group = group.strip.downcase
        
        if ['chestguard', 'helm', 'gloves', 'leggings', 'spaulders'].include? piece
          # 10-man
          return ( group == 'lost' ) ? 200 : 219
        else
          # 25-man
          return ( group == 'lost' ) ? 213 : 226
        end
      end
  end
end