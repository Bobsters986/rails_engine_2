class Item < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true
  validates :unit_price, presence: true, numericality: true
  validates :merchant_id, presence: true
  # validate :merchant_id_exists

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items, dependent: :destroy

  def summon_one_item_invoices
    invoices
    .joins(:invoice_items)
    .group(:id)
    .having("COUNT(invoice_items.id) = 1")
  end

  def self.find_by_name(criteria)
    where("name ILIKE ?", "%#{criteria}%")
    .order(:name)
  end

  def self.price_greater_or_eq(min)
    where("unit_price >= ?", min)
    .order(:unit_price)
  end

  def self.price_less_or_eq(max)
    where("unit_price <= ?", max)
    .order(:unit_price)
  end

  def self.in_between_prices(min, max)
    where("unit_price >= :min AND unit_price <= :max", {min: min, max: max})
    .order(:unit_price)
  end

  def self.get_top_items_by_revenue(quantity)
    joins(invoice_items: [{ invoice: :transactions }])
    .where(transactions: { result: 'success' }, invoices: { status: 'shipped' })
    .select("items.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue")
    .group(:id)
    .order("revenue DESC")
    .limit(quantity)
  end

  # def merchant_id_exists
  #   begin
  #     Merchant.find(self.merchant_id)
  #   rescue ActiveRecord::RecordNotFound
  #     errors.add(:merchant_id, "merchant_id foreign key must exist")
  #     false
  #   end
  # end
end