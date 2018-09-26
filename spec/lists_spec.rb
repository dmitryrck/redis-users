require "spec_helper"

describe App::Application, type: :feature do
  before { $redis.keys != [] && $redis.del($redis.keys) }

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

    it "should add a new user" do
      visit "/"
      fill_in "Name", with: "list1"
      click_on "Submit"
      click_on "New User"
      fill_in "Name", with: "John Doe"
      fill_in "Email", with: "john.doe@example.com"
      fill_in "Password", with: "secret"
      click_on "Submit"

      expect(page).to have_content "John Doe"
      expect(page).to have_content "john.doe@example.com"
    end

    it "should be able to delete" do
      visit "/"
      fill_in "Name", with: "list1"
      click_on "Submit"
      click_on "New User"
      fill_in "Name", with: "John Doe"
      fill_in "Email", with: "john.doe@example.com"
      fill_in "Password", with: "secret"
      click_on "Submit"

      expect { click_on "Delete" }
        .to change { page.has_content?("John Doe") }
    end

    context "should not add a new user without" do
      before do
        visit "/"
        fill_in "Name", with: "list1"
        click_on "Submit"
        click_on "New User"
      end

      it "email" do
        fill_in "Name", with: "John Doe"
        fill_in "Password", with: "secret"
        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end

      it "password" do
        fill_in "Name", with: "John Doe"
        fill_in "Email", with: "john.doe@example.com"
        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end
    end
  end
end
