class Profile < ActiveRecord::Base
  belongs_to :user

  validate :not_null_at_same_time
  validates :gender, inclusion: { in: %w(female male) }
  validate :male_cannot_have_female_name

  def not_null_at_same_time
  	if !first_name && !last_name
  		errors.add(:first_name, "Cannot be null when last_name is null!")
  	end
  end

  def male_cannot_have_female_name
  	if gender == "male" && first_name == "Sue"
  		errors.add(:first_name, "Cannot have a female name")
  	end
  end

  def self.get_all_profiles(min, max)
  	Profile.where("birth_year BETWEEN ? AND ?", min, max).order("birth_year ASC")
  end
end
