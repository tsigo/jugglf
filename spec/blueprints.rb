require 'faker'

# Sham attribute definitions
Sham.define do
  name { Faker::Name.first_name }
  price(:unique => false) { 1.0 }
end

Member.blueprint do
  name
end

Raid.blueprint do
  date { Date.today }
end

Attendee.blueprint do
  raid
  member
  attendance { 0.85 }
end

Item.blueprint do
  name
  member
  raid
end

Punishment.blueprint do
  member
  reason { Faker::Lorem.sentence(5) }
  expires { Date.tomorrow }
  value { Sham.price }
end
Punishment.blueprint(:expired) do
  expires { Date.yesterday }
end