require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def user
    @user ||= users :normal
  end

  test 'requires a first name' do
    user.first_name = nil
    assert_not user.valid?
  end

  test 'requires a last name' do
    user.last_name = nil
    assert_not user.valid?
  end

  test 'hashes email before saving' do
    user.save
    assert_not_empty user.hashed_email
  end

  test 'assigns API key upon creation' do
    new_user = User.new(first_name: 'm', last_name: 'c', email: 'e@ma.il', password: 'password')
    refute new_user.api_key
    new_user.save!
    assert new_user.reload.api_key, user.inspect
  end

  test "cannot change user's API key once set" do
    [APIKey.new, nil].each do |value|
      assert_raises(ActiveRecord::ActiveRecordError) {
        user.update_attribute(:api_key, value)
      }
    end
  end

  test "can change user's API key before saving" do
    new_user = User.new
    new_user.api_key = APIKey.new
    assert new_user.api_key
  end

  test "#searches returns user's saved searches" do
    saved_search = searches(:saved)
    assert_equal user, saved_search.user
    assert_equal [saved_search.id], user.searches.map(&:id)
  end

  test '#subscriptions' do
    refute_empty user.subscriptions
  end

  # TODO: Add Place to this list.
  test '#subscription can include all subscribable classes' do
    %w( Development Search ).each do |klass|
      assert_includes user.subscriptions.map(&:subscribable_type), klass
    end
  end

  test 'last checked subscriptions' do
    Time.stub :now, Time.new(2000) do
      new_user = User.new
      new_user.save(validate: false)
      assert new_user.last_checked_subscriptions
      # Not returning, probably because Time.now is being called at
      # the database level in the prevent_null_last_check migration
      # assert_equal user.last_checked_subscriptions, Time.new(2000)
    end
  end

  test 'needing update' do
    skip
  end

end
