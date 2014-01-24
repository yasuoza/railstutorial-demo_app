class Relationship < ActiveRecord::Base
  belongs_to :follower
  belongs_to :followered
end
