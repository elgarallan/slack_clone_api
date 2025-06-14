class CreateDirectMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :direct_messages do |t|
      t.text :body
      t.integer :sender_id
      t.integer :receiver_id

      t.timestamps
    end
  end
end
