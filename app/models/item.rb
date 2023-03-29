class Item < ApplicationRecord
  validates :name, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true
  # validate :merchant_id_exists

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items


  # def merchant_id_exists
  #   begin
  #     Merchant.find(self.merchant_id)
  #   rescue ActiveRecord::RecordNotFound
  #     errors.add(:merchant_id, "merchant_id foreign key must exist")
  #     false
  #   end
  # end
end