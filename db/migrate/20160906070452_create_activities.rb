class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :target_id
      t.integer :action_type
      t.integer :count_correct
      t.timestamps null: false
    end
  end
end
