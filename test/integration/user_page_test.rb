require 'test_helper'

class UserPagesIndexIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  teardown do
    reset_session!
  end

  test 'page' do
    visit users_path
    assert page.has_title?('All users')
    assert page.has_content?('All users')
  end

  test 'pagination' do
    30.times { FactoryGirl.create(:user) }
    visit users_path
    User.paginate(page: 1).each do |user|
      assert page.has_selector?('li', text: user.name)
    end
  end

  test 'delete links' do
    visit users_path
    assert_not page.has_link?('delete')
  end

  test 'delete links as an admin user' do
    admin = FactoryGirl.create(:admin)
    sign_in admin
    visit users_path

    assert page.has_link?('delete', href: user_path(User.first))
    assert_difference 'User.count', -1 do
      click_link('delete', match: :first)
    end
    assert_not page.has_link?('delete', href: user_path(admin))
  end
end


require 'test_helper'

class UserPagesIndexIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    @m1 = FactoryGirl.create(:micropost, user: @user, content: "Foo")
    @m1 = FactoryGirl.create(:micropost, user: @user, content: "Foo")
    @m2 = FactoryGirl.create(:micropost, user: @user, content: "Bar")
    sign_in @user
  end

  teardown do
    reset_session!
  end

  test '@user' do
    visit user_path(@user)

    assert page.has_content?(@user.name)
    assert page.has_title?(@user.name)
  end

  test 'microposts' do
    visit user_path(@user)
    page.has_content?(@m1.content)
    page.has_content?(@m2.content)
    page.has_content?(@user.microposts.count)
  end
end

class FollowUnfollowButtonIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    @other_user = FactoryGirl.create(:user)
    sign_in @user
  end

  teardown do
    reset_session!
  end

  test "follow/unfollow buttons" do
    visit user_path(@other_user)
    assert_difference ['@user.followed_users.count', '@other_user.followers.count'], 1 do
      click_button "Follow"
    end
  end

  test "toggling the follow button" do
    visit user_path(@other_user)
    click_button "Follow"
    assert page.has_xpath?("//input[@value='Unfollow']")
  end

  test "unfollowing a user" do
    @user.follow!(@other_user)
    visit user_path(@other_user)

    assert_difference ['@user.followed_users.count', '@other_user.followers.count'], -1 do
      click_button "Unfollow"
    end
  end

  test "toggling the unfollow button" do
    @user.follow!(@other_user)
    visit user_path(@other_user)
    click_button "Unfollow"
    assert page.has_xpath?("//input[@value='Follow']")
  end
end


class SignUpPageIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    visit signup_path
    @submit = "Create my account"
  end

  teardown do
    reset_session!
  end

  test "with invalid information" do
    assert_no_difference 'User.count' do
      click_button @submit
    end
  end

  test "with valid information" do
    fill_in "Name",         with: "Example User"
    fill_in "Email",        with: "user@example.com"
    fill_in "Password",     with: "foobar"
    fill_in "Confirmation", with: "foobar"

    assert_difference 'User.count', 1 do
      click_button @submit
    end

    user = User.find_by(email: 'user@example.com')
    assert page.has_link?('Sign out')
    assert has_title?(user.name)
    assert has_selector?('div.alert.alert-success', text: 'Welcome')
  end
end


class EditUserIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    @other_user = FactoryGirl.create(:user)
    sign_in @user
    visit edit_user_path(@user)
  end

  teardown do
    reset_session!
  end

  test "edit" do
    assert page.has_content?("Update your profile")
    assert page.has_title?("Edit user")
    assert page.has_link?('change', href: 'http://gravatar.com/emails')
  end

  test "with valid information" do
    new_name = "New Name"
    new_email = "new@example.com"
    fill_in "Name",             with: new_name
    fill_in "Email",            with: new_email
    fill_in "Password",         with: @user.password
    fill_in "Confirm Password", with: @user.password
    click_button "Save changes"

    assert page.has_title?(new_name)
    assert page.has_selector?('div.alert.alert-success')
    assert page.has_link?('Sign out', href: signout_path)
    assert @user.reload.name == new_name
    assert @user.reload.email == new_email
  end
end


class FollowUnfollowIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    @other_user = FactoryGirl.create(:user)
    @user.follow!(@other_user)
  end

  teardown do
    reset_session!
  end

  test "following/followers" do
    sign_in @user
    visit following_user_path(@user)
    assert page.has_title?(full_title('Following'))
    assert page.has_selector?('h3', text: 'Following')
    assert page.has_link?(@other_user.name, href: user_path(@other_user))
  end

  test "followers" do
    sign_in @other_user
    visit followers_user_path(@other_user)
    assert page.has_title?(full_title('Followers'))
    assert page.has_selector?('h3', text: 'Followers')
    assert page.has_link?(@user.name, href: user_path(@user))
  end
end
