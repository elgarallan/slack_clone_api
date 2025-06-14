class Channel < ApplicationRecord
  belongs_to :team
  has_many :messages
end
