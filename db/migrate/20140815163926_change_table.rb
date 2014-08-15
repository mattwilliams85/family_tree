class ChangeTable < ActiveRecord::Migration
  def change
    add_column :people, :mother_id, :int
    add_column :people, :father_id, :int
  end
end
