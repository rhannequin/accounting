class Transaction < ApplicationRecord
  monetize :amount_cents

  validates :bankin_id, uniqueness: true
end
