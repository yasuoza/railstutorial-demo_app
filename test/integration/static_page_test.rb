require 'test_helper'

class StaticPagesIndexIntegrationTest < ActionDispatch::IntegrationTest
  teardown do
    reset_session!
  end

  test "Home page" do
    visit root_path
    assert page.has_selector?('h1', :text => 'Sample App')
    assert page.title == full_title('')
    assert page.title == "Ruby on Rails Tutorial Sample App"
  end

  test "for signed-in users" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
    FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
    sign_in user
    visit root_path

    user.feed.each do |item|
      assert page.has_selector?("li##{item.id}", text: item.content)
    end
  end

  test "follower/following counts" do
    user = FactoryGirl.create(:user)
    other_user = FactoryGirl.create(:user)
    other_user.follow!(user)
    sign_in user
    visit root_path

    assert page.has_link?("0 following", href: following_user_path(user))
    assert page.has_link?("1 followers", href: followers_user_path(user))
  end

  test "Help page" do
    visit help_path
    assert page.has_selector?('h1', :text => 'Help')
    assert page.title == full_title('Help')
    assert page.title == "Ruby on Rails Tutorial Sample App | Help"
  end

  test "About page" do
    visit about_path

    assert page.has_selector?('h1', :text => 'About Us')
    assert page.title == full_title('About Us')
    assert page.title == "Ruby on Rails Tutorial Sample App | About Us"
  end

  test "Contact page" do
    visit contact_path
    assert page.has_selector?('h1', text: 'Contact')
    assert page.title == full_title('Contact')
    assert page.title == "Ruby on Rails Tutorial Sample App | Contact"
  end
end

