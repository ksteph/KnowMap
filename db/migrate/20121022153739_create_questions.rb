class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :node_id,        :null => false
      t.string  :type
      t.text    :text,         :null => false
      t.text    :choices
      t.text    :answers,        :null => false
      t.text    :explanations
      t.text    :hint
      t.text :json
      t.string :title

      t.timestamps
    end
  end
end
