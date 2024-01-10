class DnsRecord < ApplicationRecord
  has_many :hostnames, dependent: :destroy
  accepts_nested_attributes_for :hostnames

  validates :ip, presence: true
end
