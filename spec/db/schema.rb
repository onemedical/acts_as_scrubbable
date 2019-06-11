ActiveRecord::Schema.define(version: 20150421224501) do

  create_table "scrubbable_models", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "middle_name"
    t.string   "name"
    t.string   "email"
    t.string   "title"
    t.string   "company_name"
    t.string   "address1"
    t.string   "address2"
    t.string   "zip_code"
    t.string   "state"
    t.string   "state_short"
    t.string   "city"
    t.string   "lat"
    t.string   "lon"
    t.string   "username"
    t.boolean  "active"
    t.string   "school"
  end

end
