class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :node_id,        :null => false
      t.string  :type
      t.text    :prompt,         :null => false
      t.text    :choices
      t.text    :answers,        :null => false
      t.text    :explanations
      t.text    :hint

      t.timestamps
    end
  end
end
