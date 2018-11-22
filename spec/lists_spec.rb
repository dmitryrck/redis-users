require "spec_helper"

describe App::Application, type: :feature do
  before { redis.keys != [] && redis.del(redis.keys) }

  let(:redis) { Redis.new(url: ENV["REDIS_URL"]) }

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

    context "when there is a user in the database " do
      before do
        visit "/"
        fill_in "Name", with: "list1"
        click_on "Submit"
        click_on "New User"
        fill_in "Name", with: "John Doe"
        fill_in "Email", with: "john.doe@example.com"
        fill_in "Password", with: "secret"
        click_on "Submit"
      end

      it "should be able to delete" do
        expect { click_on "Delete" }
          .to change { page.has_content?("John Doe") }
      end

      it "should be able to update" do
        click_on "Edit"

        fill_in "Name", with: "Alice Doe"
        fill_in "Email", with: "alice.doe@example.com"
        fill_in "Password", with: "secret"

        click_on "Submit"

        expect(page).to have_content "Alice Doe"
        expect(page).to have_content "alice.doe@example.com"
      end

      it "should not be able to update without password" do
        click_on "Edit"

        fill_in "Name", with: "Alice Doe"
        fill_in "Email", with: "alice.doe@example.com"

        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end

      it "should not be able to update without email" do
        click_on "Edit"

        fill_in "Name", with: "Alice Doe"
        fill_in "Email", with: ""

        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end

      it "should be able to login" do
        click_on "Login"

        fill_in "Email", with: "john.doe@example.com"
        fill_in "Password", with: "secret"

        click_on "Submit"

        expect(page).to have_content "Welcome, John Doe"
      end

      it "should not be able to login with wrong email" do
        click_on "Login"

        fill_in "Email", with: "john.doe@example"
        fill_in "Password", with: "secret"

        click_on "Submit"

        expect(page).to have_content "Wrong Email or Password"
      end

      it "should not be able to login with wrong password" do
        click_on "Login"

        fill_in "Email", with: "john.doe@example.com"
        fill_in "Password", with: "other password"

        click_on "Submit"

        expect(page).to have_content "Wrong Email or Password"
      end
    end

    context "should not add a new user without" do
      before do
        visit "/"
        fill_in "Name", with: "list1"
        click_on "Submit"
        click_on "New User"
        fill_in "Name", with: "John Doe"
      end

      it "email" do
        fill_in "Password", with: "secret"
        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end

      it "password" do
        fill_in "Email", with: "john.doe@example.com"
        click_on "Submit"

        expect(page).to have_content "Email and password are mandatory"
      end
    end
  end
end
