class Merchant < ApplicationRecord
  validates_presence_of :name
  
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :items
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def self.find_by_name(criteria)
    where("name ILIKE ?", "%#{criteria}%")
    .order(:name)
    .first
  end
end