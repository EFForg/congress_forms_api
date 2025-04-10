class AddReasonToDefunctCongressForms < ActiveRecord::Migration[6.1]
  def change
    add_column :defunct_congress_forms, :reason, :string
  end
end
