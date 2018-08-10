class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false, limit: 255
      t.string :code, null: false, limit: 6

      t.timestamps
    end

    add_index :companies, :code, unique: true
  end
end
