require 'spec_helper'

class TestOrderRequest < CafePress::EZP::Client::OrderRequest
  def send
    build
  end
end

RSpec.describe CafePress::EZP::Client::OrderRequest do
  context 'when given a customer' do
    it 'includes the customer in the request' do
      req = TestOrderRequest.new(:customer => customer)
      expect(req.send).to equal_xml("<a>123</a>")
    end
  end
end
