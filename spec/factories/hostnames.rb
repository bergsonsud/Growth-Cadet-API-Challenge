FactoryBot.define do
  factory :hostname do
    hostname { Faker::Internet.domain_name }
    association :dns_record, factory: :dns_record

    trait :dolor do
      hostname { 'dolor.com' }
    end

    trait :amet do
      hostname { 'amet.com' }
    end

    trait :ipsum do
      hostname { 'ipsum.com' }
    end
  end
end
