ActiveRecord::Schema.define(version: 20150421224501) do
  create_table "scrubbable_models", force: true do |t|
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "address1"
    t.string   "lat"
  end

  create_table "sterilizable_models", force: true do |t|
    t.string   "irrelevant"
  end
end
