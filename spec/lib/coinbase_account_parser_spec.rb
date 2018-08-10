require 'spec_helper'
require "rails_helper"

describe CoinbaseAccountParser do

    describe "#.get_account" do

        it "returns true and Account object upon successful request to Coinbase API" do
            cap = CoinbaseAccountParser.new
            cap_retval = cap.get_account(ENV['API_KEY'],ENV['API_SECRET'])
            expect(cap_retval).to eql true
            expect(cap.account).to be_truthy 
            expect(cap.error).to eql nil 
        end

        it "returns false and error message upon unsuccessful request to Coinbase API" do
            cap = CoinbaseAccountParser.new
            cap_retval = cap.get_account('bogus_api_key','bogus_api_secret')
            expect(cap_retval).to eql false
            expect(cap.account).to eql nil 
            expect(cap.error).to be_truthy 
        end

    end

end





