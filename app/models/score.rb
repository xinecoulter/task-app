class Score < ActiveRecord::Base
  belongs_to :team, touch: true
  belongs_to :member, class_name: "User", touch: true

  validates_uniqueness_of :member_id, scope: :team_id

end
