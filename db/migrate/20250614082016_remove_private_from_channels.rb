class RemovePrivateFromChannels < ActiveRecord::Migration[8.0]
  def change
    remove_column :channels, :private, :boolean
  end
end
