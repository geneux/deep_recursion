class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :question, index: true, foreign_key: true
      t.text :body, null: false, limit: 50_000
      t.integer :rating, null: false, default: 0

      t.timestamps null: false
    end
  end
end
