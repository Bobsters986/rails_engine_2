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

  let!(:merchant_1) { create(:merchant) }
  let!(:item_1) { create(:item, name: "The One Ring", unit_price: 300.00, merchant: merchant_1) }
  let!(:item_2) { create(:item, name: "Ring Pop", unit_price: 100.00, merchant: merchant_1) }
  let!(:item_3) { create(:item, name: "The Ringer", unit_price: 150.00, merchant: merchant_1) }
  let!(:item_4) { create(:item, name: "X Box", unit_price: 400.00, merchant: merchant_1) }
  let!(:item_5) { create(:item, name: "PS-5", unit_price: 500.00, merchant: merchant_1) }

  let!(:customer_1) { create(:customer) }
  let!(:customer_2) { create(:customer) }

  let!(:inv_1) { create(:invoice, merchant: merchant_1, customer: customer_1) }
  let!(:inv_2) { create(:invoice, merchant: merchant_1, customer: customer_2) }
  let!(:inv_3) { create(:invoice, merchant: merchant_1, customer: customer_2) }
  
  describe "#instance methods" do
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

  describe "class methods" do
    describe ".find_by_name" do
      context "it is case insensitive, in alphabetical order, grabs all results" do
        it "finds all items by search criteria" do
          searched_item = Item.find_by_name("ring")

          expect(searched_item).to eq([item_2, item_1, item_3])
          expect(searched_item).to_not eq([item_4])
        end
      end

      it "returns nil if no items are found" do
        searched_item = Item.find_by_name("wrong")
        
        expect(searched_item).to eq([])
      end
    end

    describe ".price_greater_or_eq" do
      it "returns items if they are greater than a certain threshold" do
        expect(Item.price_greater_or_eq(300.00)).to eq([item_1, item_4, item_5])
        expect(Item.price_greater_or_eq(300.01)).to eq([item_4, item_5])
        expect(Item.price_greater_or_eq(300.01)).to_not include(item_1, item_2, item_3)
      end
    end

    describe ".price_less_or_eq" do
      it "returns items if they are less than a certain threshold" do
        expect(Item.price_less_or_eq(300.00)).to eq([item_2, item_3, item_1])
        expect(Item.price_less_or_eq(299.99)).to eq([item_2, item_3])
        expect(Item.price_less_or_eq(299.99)).to_not include(item_1, item_4, item_5)
      end
    end

    describe ".in_between_prices" do
      it "returns items if they are in between two threshold" do
        expect(Item.in_between_prices(150.00, 400.00)).to eq([item_3, item_1, item_4])
        expect(Item.in_between_prices(150.00, 400.00)).to_not include(item_2, item_5)
        expect(Item.in_between_prices(300.00, 499.00)).to eq([item_1, item_4])
        expect(Item.in_between_prices(300.00, 499.00)).to_not include(item_2, item_3, item_5)
      end
    end

  end
end