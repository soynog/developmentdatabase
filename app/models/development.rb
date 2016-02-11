class Development < ActiveRecord::Base
  # TODO basic geocoding
  # geocoded_by :full_street_address   # Implement this method
  # after_validation :geocode          # Auto-fetch coordinates
  has_one :walkscore # TODO

  extend Enumerize

  # Callbacks
  before_save :update_tagline
  before_save :clean_zip_code

  # Relationships
  belongs_to :creator, class_name: :User
  belongs_to :place

  has_many :edits
  has_many :flags
  has_many :crosswalks
  has_many :team_memberships, class_name: :DevelopmentTeamMembership,
            counter_cache: :team_membership_count
  has_many :team_members, through: :team_memberships, source: :organization
  has_many :subscriptions, as: :subscribable
  has_many :subscribers, through: :subscriptions, source: :user

  has_and_belongs_to_many :programs

  # Validations
  validates :creator,    presence: true
  validates :year_compl, presence: true

  STATUSES = [:projected, :planning, :in_construction, :completed].freeze
  enumerize :status, in: STATUSES, predicates: true

  alias_attribute :website, :project_url
  alias_attribute :zip, :zip_code
  alias_attribute :hidden, :private

  # Scopes
  ranged_scopes :created_at, :updated_at, :height, :stories,
    :year_compl, :affordable, :prjarea, :singfamhu, :twnhsmmult,
    :lgmultifam, :tothu, :gqpop, :rptdemp, :emploss, :estemp, :commsf,
    :hotelrms, :onsitepark, :total_cost, :fa_ret, :fa_ofcmd,
    :fa_indmf, :fa_whs, :fa_rnd, :fa_edinst, :fa_other, :fa_hotel

  boolean_scopes :rdv, :asofright, :ovr55, :clusteros, :phased,
    :stalled, :cancelled, :hidden

  scope :close_to, CloseToQuery.new(self).scope

  def location
    [latitude, longitude].map(&:to_f)
  end

  def rlocation
    location.reverse
  end

  def zip_code
    code = read_attribute(:zip_code).to_s
    code.length == 9 ? nine_digit_formatted_zip(code) : code
  end

  def municipality
    return nil unless place
    case place.type
    when 'Municipality' then place
    when 'Neighborhood' then place.municipality
    else raise NotImplementedError, "type not defined in #{__FILE__}"
    end
  end

  alias_method :city, :municipality

  def neighborhood
    return nil unless place
    case place.type
    when 'Neighborhood' then place
    when 'Municipality' then nil
    end
  end

  def mixed_use?
    false
    # any_residential_fields? && any_commercial_fields?
  end
  # TODO: Cache this in the database, to be used for searches.
  alias_method :mixed_use, :mixed_use?

  def history(since: nil)
    scope = self.edits.where(applied: true).order(applied_at: :desc)
    scope = scope.where('applied_at > ?', since) if since
    scope
  end

  def most_recent_edit
    history.first
  end

  alias_method :last_edit, :most_recent_edit

  def pending_edits
    self.edits.where(state: 'pending').order(created_at: :asc)
  end

  def contributors
    ContributorQuery.new(self).find.map(&:editor).push(creator).uniq
  end

  def parcel
    OpenStruct.new(id: 12345)
  end

  def incentive_programs
    programs.where type: :incentive
  end

  def regulatory_programs
    programs.where type: :regulatory
  end

  def updated_since?(timestamp = Time.now)
    if history.any?
      self.last_edit.applied_at > timestamp
    else
      self.created_at > timestamp
    end
  end

  def changes_since(timestamp = Time.now)
    history.where('applied_at > ?', timestamp)
  end

  private

  def update_tagline
    self.tagline = TaglineGenerator.new(self).perform!
  end

  def clean_zip_code
    self.zip_code = self.zip_code.to_s.gsub(/\D*/, '')
  end

  def nine_digit_formatted_zip(code)
    "#{code[0..4]}-#{code[-4..-1]}"
  end

end
