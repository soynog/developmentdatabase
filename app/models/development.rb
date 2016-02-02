class Development < ActiveRecord::Base
  extend Enumerize

  before_save :update_tagline
  before_save :clean_zip_code

  # TODO basic geocoding
  # geocoded_by :full_street_address   # Implement this method
  # after_validation :geocode          # Auto-fetch coordinates

  belongs_to :creator, class_name: :User
  has_one :walkscore # TODO

  has_many :edits
  has_many :flags
  has_many :crosswalks
  has_many :team_memberships, class_name: :DevelopmentTeamMembership,
    counter_cache: :team_membership_count
  has_many :team_members, through: :team_memberships, source: :organization
  has_many :subscriptions, as: :subscribable
  has_many :subscribers, through: :subscriptions, source: :user

  has_and_belongs_to_many :programs

  validates :creator, presence: true
  validates :year_compl, presence: true

  STATUSES = [:projected, :planning, :in_construction, :completed]
  enumerize :status, :in => STATUSES, predicates: true

  alias_attribute :website, :project_url
  alias_attribute :zip, :zip_code

  scope :close_to, -> (latitude, longitude, distance_in_meters = 2000) {
    where(%{
      ST_DWithin(
        ST_GeographyFromText(
          'SRID=4326;POINT(' || developments.longitude || ' ' || developments.latitude || ')'
        ),
        ST_GeographyFromText('SRID=4326;POINT(%f %f)'),
        %d
      )
    } % [longitude, latitude, distance_in_meters])
  }

  def location
    # [longitude, latitude]
  end

  def zip_code
    code = read_attribute(:zip_code).to_s
    code.length == 9 ? nine_digit_formatted_zip(code) : code
  end

  def mixed_use?
    false
    # any_residential_fields? && any_commercial_fields?
  end
  # TODO: Cache this in the database, to be used for searches.
  alias_method :mixed_use, :mixed_use?

  def history
    self.edits.where(applied: true).order(applied_at: :desc)
  end

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
