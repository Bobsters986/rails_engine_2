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

  def self.top_merchants_by_revenue(quantity)
    joins(invoices: [:invoice_items, :transactions])
    .where(transactions: { result: 'success' }, invoices: { status: 'shipped' })
    .select(:name, :id, "SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue")
    .group(:id)
    .order(revenue: :desc)
    .limit(quantity)
  end

  def self.top_merchants_by_items(quantity)
    select("merchants.*, SUM(invoice_items.quantity) AS item_count")
    .joins(invoices: :invoice_items)
    .group(:id)
    .order("item_count DESC")
    .limit(quantity)
  end

  def revenue_for_merchant(merchant_id)
    select("merhants.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue")
    .joins(invoices: [:invoice_items, :transactions])
    .where(
      merchants: { id: merchant_id },
      transactions: { result: 'success' },
      invoices: { status: 'shipped' })
    .group(:id)
  end
end