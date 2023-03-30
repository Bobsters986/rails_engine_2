require 'rails_helper'

RSpec.describe Merchant, type: :model do

  describe "validations" do
    it { should validate_presence_of :name }
  end

  describe "relationships" do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:invoice_items).through(:items) }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many(:transactions).through(:invoices) }
  end

  describe "class methods" do
    describe ".find_by_name" do
      let!(:merchant_1) { create(:merchant, name: "Turing") }
      let!(:merchant_2) { create(:merchant, name: "Ring World") }
      let!(:merchant_3) { create(:merchant, name: "One Ring to Rule them All") }

      context "it is case insensitive, in alphabetical order, grabs first result" do
        it "finds a merchant by search criteria" do
          searched_merchant = Merchant.find_by_name("ring")

          expect(searched_merchant).to eq(merchant_3)
          expect(searched_merchant).to_not eq(merchant_2)
          expect(searched_merchant).to_not eq(merchant_1)
        end
      end

      it "returns nil if no merchant is found" do
        searched_merchant = Merchant.find_by_name("wrong")
        
        expect(searched_merchant).to eq(nil)
      end
    end
  end
end