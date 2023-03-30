require 'rails_helper'

RSpec.describe Item, type: :model do

  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :unit_price }
    it { should validate_numericality_of :unit_price }
  end

  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many :invoice_items}
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe "#instance methods" do
    let!(:merchant_1) { create(:merchant) }
    let!(:item_1) { create(:item, merchant: merchant_1) }
    let!(:item_2) { create(:item, merchant: merchant_1) }
    let!(:item_3) { create(:item, merchant: merchant_1) }

    let!(:customer_1) { create(:customer) }
    let!(:customer_2) { create(:customer) }

    let!(:inv_1) { create(:invoice, merchant: merchant_1, customer: customer_1) }
    let!(:inv_2) { create(:invoice, merchant: merchant_1, customer: customer_2) }
    let!(:inv_3) { create(:invoice, merchant: merchant_1, customer: customer_2) }

    before do
      create(:invoice_item, item: item_1, invoice: inv_1)
      create(:invoice_item, item: item_1, invoice: inv_2)
      create(:invoice_item, item: item_2, invoice: inv_2)
      create(:invoice_item, item: item_3, invoice: inv_2)
      create(:invoice_item, item: item_2, invoice: inv_3)
      create(:invoice_item, item: item_3, invoice: inv_3)
    end

    it "#summon_one_item_invoices" do
      expect(item_1.summon_one_item_invoices).to eq([inv_1])
      expect(item_2.summon_one_item_invoices).to eq([])
      expect(item_3.summon_one_item_invoices).to eq([])
    end
  end
end