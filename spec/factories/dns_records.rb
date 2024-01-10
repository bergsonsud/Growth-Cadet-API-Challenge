FactoryBot.define do
  factory :dns_record do
    ip { Faker::Internet.ip_v4_address }

    trait :dolor do
      hostnames { [create(:hostname, hostname: 'dolor.com')] }
    end

    trait :amet do
      hostnames { [create(:hostname, hostname: 'amet.com')] }
    end

    trait :ipsum do
      hostnames { [create(:hostname, hostname: 'ipsum.com')] }
    end
  end
end
