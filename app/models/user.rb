class User < ApplicationRecord
  has_secure_password

  has_many :memberships
  has_many :teams, through: :memberships

  has_many :messages
  has_many :channels, through: :messages

  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id
  has_many :received_direct_messages, class_name: "DirectMessage", foreign_key: :receiver_id
end
