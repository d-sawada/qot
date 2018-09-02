class Company < ApplicationRecord
  has_many :admins, primary_key: :code, foreign_key: :company_code,
           dependent: :destroy
  has_many :emp_statuses, primary_key: :code, foreign_key: :company_code,
           dependent: :destroy
  has_many :employees, primary_key: :code, foreign_key: :company_code,
           dependent: :destroy
  has_many :dayinfos, through: :employees,
           primary_key: :id, foreign_key: :employee_id
  has_many :requests, through: :employees,
           primary_key: :id, foreign_key: :employee_id
  has_many :emp_exes, dependent: :destroy
  has_many :work_patterns, dependent: :destroy
  has_many :work_templates, dependent: :destroy
  has_many :company_configs, dependent: :destroy
  
  validates :code, length: { is: 6 }, uniqueness: true
  validates :name, presence: true, length: { maximum: 255 }

  rails_admin do
    edit do
      configure :admins do
        visible false
      end
      configure :employees do
        visible false
      end
    end
  end
  
  after_create :create_default_configs

  def create_default_configs
    self.company_configs.build(
      key: "send_mail_request_processed", value: "送信する"
    )
    self.save
  end
end
