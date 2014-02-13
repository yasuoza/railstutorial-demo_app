require 'test_helper'

class SigninIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
  end

  teardown do
    reset_session!
  end

  test "signin page" do
    visit signin_path
    assert page.has_content?('Sign in')
    assert page.has_title?('Sign in')
  end

  test "signin" do
    visit signin_path
    click_button "Sign in"
    assert page.has_title?('Sign in')
    assert page.has_selector?('div.alert.alert-danger')
  end

  test "with valid information" do
    visit signin_path
    fill_in "Email",    with: @user.email.upcase
    fill_in "Password", with: @user.password
    click_button "Sign in"

    assert page.has_title?(@user.name)
    assert page.has_link?('Users',       href: users_path)
    assert page.has_link?('Profile',     href: user_path(@user))
    assert page.has_link?('Settings',    href: edit_user_path(@user))
    assert page.has_link?('Sign out',    href: signout_path)
    assert page.has_link?('Settings',    href: edit_user_path(@user))
    assert page.has_link?('Sign out',    href: signout_path)
    assert_not page.has_link?('Sign in', href: signin_path)

    click_link 'Sign out'
    assert page.has_link?('Sign in')
  end
end

class NotSigninIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
  end

  teardown do
    reset_session!
  end

  test "for non-signed-in users" do
    visit edit_user_path(@user)
    fill_in "Email",    with: @user.email
    fill_in "Password", with: @user.password
    click_button "Sign in"

    assert page.has_title?('Edit user')
  end

  test "in the Microposts controller" do
    post microposts_path
    assert_redirected_to signin_url

    delete micropost_path(FactoryGirl.create(:micropost))
    assert_redirected_to signin_url
  end

  test "in the Relationships controller" do
    post follow_user_path(1)
    assert_redirected_to signin_url

    delete follow_user_path(1)
    assert_redirected_to signin_url
  end

  test "in the Users controller" do
    visit edit_user_path(@user)
    assert page.has_title?('Sign in')

    patch user_path(@user)
    assert_redirected_to signin_url

    visit users_path
    assert page.has_title?('Sign in')

    visit following_user_path(@user)
    assert page.has_title?('Sign in')

    visit followers_user_path(@user)
    assert page.has_title?('Sign in')
  end

  test "as wrong user" do
    wrong_user = FactoryGirl.create(:user, email: "wrong@example.com")
    sign_in @user, no_capybara: true

    get edit_user_path(wrong_user)
    assert_not response.body.match(full_title('Edit user'))
    assert_redirected_to root_path

    patch user_path(wrong_user)
    assert_redirected_to root_path
  end

  test "as non-admin user" do
    non_admin = FactoryGirl.create(:user)
    sign_in non_admin, no_capybara: true
    delete user_path(@user)
    assert_redirected_to root_path
  end
end
