class CreateDefunctCongressForm < ActiveRecord::Migration[5.2]
  def change
    create_table :defunct_congress_forms do |t|
      t.string :bioguide_id, null: false

      t.timestamps
    end

    add_index :defunct_congress_forms, :bioguide_id, unique: true
  end
end
