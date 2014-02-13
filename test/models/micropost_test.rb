require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  setup do
    @user = FactoryGirl.create(:user)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test '@micropost' do
    assert @micropost.respond_to?(:content)
    assert @micropost.respond_to?(:user_id)
    assert @micropost.respond_to?(:user)
    assert @micropost.user == @user
    assert @micropost.valid?
  end

  test "when user_id is not present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "with blank content" do
    @micropost.content = " "
    assert_not @micropost.valid?
  end

  test "with content that is too long" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end
end

