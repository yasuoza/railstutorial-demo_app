require 'spec_helper'

describe "Static pages" do

  subject { page }

  describe "Home page" do
    before { visit root_path }

    it { should have_selector('h1', :text => 'Sample App') }

    it "should have the full_title('')" do
      expect(page.title).to eql full_title('')
    end

    it "should have the title 'Home'" do
      expect(page.title).to eql "Ruby on Rails Tutorial Sample App"
    end
  end

  describe "Help page" do
    before { visit help_path }

    it { should have_selector('h1', :text => 'Help') }

    it "should have the full_title('Help')" do
      expect(page.title).to eql full_title('Help')
    end

    it "should have the title 'Help'" do
      expect(page.title).to eql "Ruby on Rails Tutorial Sample App | Help"
    end
  end

  describe "About page" do
    before { visit about_path }

    it { should have_selector('h1', :text => 'About Us') }

    it "should have the full_title('About Us')" do
      expect(page.title).to eql full_title('About Us')
    end

    it "should have the title 'About Us'" do
      expect(page.title).to eql "Ruby on Rails Tutorial Sample App | About Us"
    end
  end

  describe "Contact page" do
    before { visit contact_path }

    it { should have_selector('h1', text: 'Contact') }

    it "should have the full_title('Contact')" do
      expect(page.title).to eql full_title('Contact')
    end

    it "should have the title 'Contact'" do
      expect(page.title).to eql "Ruby on Rails Tutorial Sample App | Contact"
    end
  end
end
