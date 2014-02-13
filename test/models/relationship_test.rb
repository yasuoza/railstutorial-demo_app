require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  setup do
    @follower = FactoryGirl.create(:user)
    @followed = FactoryGirl.create(:user)
    @relationship = @follower.relationships.build(followed_id: @followed.id)
  end

  test '@relationship' do
    assert @relationship.valid?
  end

  test "follower methods" do
    assert @relationship.respond_to?(:follower)
    assert @relationship.respond_to?(:followed)
    assert @relationship.follower == @follower
    assert @relationship.followed == @followed
  end

  test "when followed id is not present" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end

  test "when follower id is not present" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
end
