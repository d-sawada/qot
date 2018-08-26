class CreateCompanyConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :company_configs do |t|
      t.integer :company_id
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
