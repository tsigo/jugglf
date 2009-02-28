require 'faker'

Sham.define do
end

ItemStat.blueprint do
  item_id { Faker::Address.zip_code }
  item { Faker::Lorem.words(2) }
  slot { 'Head' }
  level { 226 }
end