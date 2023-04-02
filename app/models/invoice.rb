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

  def self.total_revenue_by_date(start_date, end_date)
    joins(:invoice_items, :transactions)
    .where(invoices: { created_at: start_date..end_date, status: 'shipped' },
           transactions: { result: 'success' })
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def self.total_revenue_invoices_unshipped(quantity)
    joins(:invoice_items, :transactions)
    .where(invoices: { status: 'packaged' },
           transactions: { result: 'success' })
    .select('invoices.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS potential_revenue')
    .group(:id)
    .order('potential_revenue DESC')
    .limit(quantity)
  end

  def self.total_revenue_by_week(week)
    joins(:invoice_items, :transactions)
    .select('date_trunc(\'week\', invoices.created_at) AS week, SUM(invoice_items.quantity * invoice_items.unit_price) AS revenue')
    .where(invoices: { status: 'shipped' },
           transactions: { result: 'success' })
    .group('week')
    .order('week ASC')
  end
end