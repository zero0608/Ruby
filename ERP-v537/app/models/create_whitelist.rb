class CreateWhitelist < ApplicationRecord
  enum status: [ :enable, :disable ], _default: :enable
end
