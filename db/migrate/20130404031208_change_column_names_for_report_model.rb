class ChangeColumnNamesForReportModel < ActiveRecord::Migration
  def up
    change_table :reports do |t|
        t.rename :object, :reported_object
        t.rename :object_id, :reported_object_id
    end
  end

  def down
    change_table :reports do |t|
        t.rename :reported_object, :object
        t.rename :reported_object_id, :object_id
    end
  end
end
