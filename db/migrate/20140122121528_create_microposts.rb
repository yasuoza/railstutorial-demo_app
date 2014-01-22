class CreateMicroposts < ActiveRecord::Migration
  def change
    create_table :microposts do |t|
      t.string :content
      t.references :user_id, index: true

      t.timestamps
    end
  end
end
