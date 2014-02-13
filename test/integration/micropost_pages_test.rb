require 'test_helper'

class MicropostIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  teardown do
    reset_session!
  end

  test "micropost creation" do
    visit root_path

    assert_no_difference 'Micropost.count' do
      click_button 'Post'
    end

    click_button 'Post'
    assert page.has_content?('error')
  end

  test "with valid information" do
    visit root_path
    fill_in 'micropost_content', with: "Lorem ipsum"

    assert_difference 'Micropost.count', 1 do
      click_button "Post"
    end
  end

  test "micropost destruction" do
    FactoryGirl.create(:micropost, user: @user)
    visit root_path

    assert_difference 'Micropost.count', -1 do
      click_link "delete"
    end
  end
end
