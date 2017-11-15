class Authorization < ApplicationRecord
  belongs_to :playlist
  belongs_to :user, optional: true
  belongs_to :temp_user, optional: true
end
