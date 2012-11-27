class CreateQuestionSubmissions < ActiveRecord::Migration
  def change
    create_table :question_submissions do |t|
      t.integer :user_id,           :null => false
      t.integer :node_id,           :null => false
      t.integer :question_id,       :null => false
      t.text    :student_answers
      t.boolean :correct

      t.timestamps
    end
  end
end
