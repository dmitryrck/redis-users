require "spec_helper"

describe App::Application, type: :feature do
  context "GET /" do
    it "should be ok" do
      get "/"
      expect(last_response.status).to be(200)
    end

    it "should select a list" do
      visit "/"
      fill_in "Name", with: "list1"
      click_on "Submit"

      expect(page).to have_content "List: list1"
    end
  end
end
