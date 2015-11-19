ActiveRecord::Schema.define(version: 20150421224501) do

  create_table "scrubbable_models", force: true do |t|
    t.string   "first_name"
    t.string   "address1"
    t.string   "lat"
  end

end
