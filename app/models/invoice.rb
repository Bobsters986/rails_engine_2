class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id,
                        :merchant_id

  belongs_to :customer
  belongs_to :merchant
  has_many :transactions, dependent: :destroy
  has_many :invoice_items
  has_many :items, through: :invoice_items, dependent: :destroy
  has_many :merchants, through: :items
end