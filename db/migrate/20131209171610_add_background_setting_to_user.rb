class AddBackgroundSettingToUser < ActiveRecord::Migration
  def change
    add_column :users, :only_locations_backgrounds, :boolean
  end
end
