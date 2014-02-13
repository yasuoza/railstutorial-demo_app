require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test 'user.methods' do
    assert @user.respond_to?(:name)
    assert @user.respond_to?(:name)
    assert @user.respond_to?(:email)
    assert @user.respond_to?(:password_digest)
    assert @user.respond_to?(:password)
    assert @user.respond_to?(:password_confirmation)
    assert @user.respond_to?(:remember_token)
    assert @user.respond_to?(:authenticate)
    assert @user.respond_to?(:admin)
    assert @user.respond_to?(:microposts)
    assert @user.respond_to?(:feed)
    assert @user.respond_to?(:relationships)
    assert @user.respond_to?(:followed_users)
    assert @user.respond_to?(:following?)
    assert @user.respond_to?(:follow!)
    assert @user.respond_to?(:unfollow!)
    assert @user.respond_to?(:reverse_relationships)
    assert @user.respond_to?(:followers)

    assert @user.valid?
    assert_not @user.admin?
  end

  test "with admin attribute set to 'true'" do
    @user.save!
    @user.toggle!(:admin)
    assert @user.admin?
  end

  test "when name is not present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "when email is not present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "when name is too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "when email format is invalid" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
    addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?
    end
  end

  test "when email format is valid" do
    addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?
    end
  end

  test "when email address is already taken" do
    user_with_same_email = @user.dup
    user_with_same_email.save
    assert !@user.valid?
  end

  test "when same email address is already taken" do
    user_with_same_email = @user.dup
    user_with_same_email.email = @user.email.upcase
    user_with_same_email.save
    assert_not @user.valid?
  end

  test "with a password that's too short" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "return value of authenticate method" do
    @user.save
    found_user = User.find_by_email(@user.email)
    assert @user == found_user.authenticate(@user.password)

    user_for_invalid_password = found_user.authenticate("invalid")
    assert @user != user_for_invalid_password
    assert_not user_for_invalid_password
  end

  test "remember token" do
    @user.save
    assert @user.remember_token.present?
  end

  test "micropost associations" do
    @user.save
    older_micropost = FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    newer_micropost = FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    assert @user.microposts.to_a == [newer_micropost, older_micropost]

    microposts = @user.microposts.to_a
    @user.destroy
    assert microposts.present?
    microposts.each do |micropost|
      assert Micropost.where(id: micropost.id).blank?
    end
  end

  test "micopost assciations' status" do
    @user.save
    older_micropost = FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    newer_micropost = FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    unfollowed_post = FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
    assert @user.feed.include?(newer_micropost)
    assert @user.feed.include?(older_micropost)
    assert_not @user.feed.include?(unfollowed_post)

    followed_user = FactoryGirl.create(:user)
    @user.follow!(followed_user)
    3.times { followed_user.microposts.create!(content: "Lorem ipsum") }

    assert @user.feed.include?(newer_micropost)
    assert @user.feed.include?(older_micropost)
    assert_not @user.feed.include?(unfollowed_post)
    followed_user.microposts.each do |micropost|
      assert @user.feed.include?(micropost)
    end
  end

  test "following" do
    other_user = FactoryGirl.create(:user)
    @user.save
    @user.follow!(other_user)

    assert @user.following?(other_user)
    assert @user.followed_users.include?(other_user)
  end

  test "followed user" do
    other_user = FactoryGirl.create(:user)
    @user.save
    @user.follow!(other_user)

    assert other_user.followers.include?(@user)
  end

  test "unfollowing" do
    other_user = FactoryGirl.create(:user)
    @user.save
    @user.follow!(other_user)

    @user.unfollow!(other_user)
    assert_not @user.following?(other_user)
    assert_not other_user.followed_users.include?(@user)
  end
end
