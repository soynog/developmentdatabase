class Membership < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :organization
  alias_attribute :member, :user

  validates :user, presence: true
  validates :organization, presence: true, uniqueness: {
    scope: [:user_id],
    conditions: -> { where.not(state: :inactive) },
    message: 'You have already requested to join that organization.'
  }

  enumerize :state, in: [:pending, :invited, :active, :inactive],
    default: :pending, predicates: true

  def invited
    self.state = :invited
    self
  end

  def activated
    self.state = :active
    self
  end

  def deactivated
    self.state = :inactive
    self
  end
end
