class CreateHostnames < ActiveRecord::Migration[6.1]
  def change
    create_table :hostnames do |t|
      t.references :dns_record, null: false, foreign_key: true, index: true
      t.string :hostname, index: true

      t.timestamps
    end
  end
end
