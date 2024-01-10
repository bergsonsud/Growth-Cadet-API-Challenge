class Hostname < ApplicationRecord
  belongs_to :dns_record

  validates :hostname, hostname: true, presence: true
end
