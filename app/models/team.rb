class Team < ApplicationRecord
    has_many :users, dependent: :nullify
end
