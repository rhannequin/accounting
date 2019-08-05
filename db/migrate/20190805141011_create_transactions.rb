class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.integer :bankin_id, limit: 8
      t.string :title
      t.monetize :amount
      t.date :date
      t.timestamps

      t.index(:bankin_id, unique: true)
    end
  end
end
