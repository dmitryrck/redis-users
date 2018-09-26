require "spec_helper"

describe App::Application do
  context "GET /" do
    it "should be ok" do
      get "/"
      expect(last_response.status).to be(200)
    end
  end
end
