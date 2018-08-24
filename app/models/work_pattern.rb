class WorkPattern < ApplicationRecord
    belongs_to :company

    validates :company_id, presence: true
    validates :name,  presence: true
    validates :start, presence: true
    validates :end,   presence: true
    validates :start_day, inclusion: { in: %w(前日 当日 翌日) }
    validates :end_day,   inclusion: { in: %w(前日 当日 翌日) }
end
