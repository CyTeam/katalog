# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100520204948) do

  create_table "dossier_numbers", :force => true do |t|
    t.integer  "dossier_id"
    t.date     "to"
    t.date     "from"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dossier_numbers", ["dossier_id"], :name => "index_dossier_numbers_on_dossier_id"

  create_table "dossiers", :force => true do |t|
    t.string   "signature"
    t.string   "title"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id"
    t.string   "type"
    t.integer  "parent_id"
  end

  add_index "dossiers", ["signature"], :name => "index_dossiers_on_signature"

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "availability"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"

  create_table "topics", :force => true do |t|
    t.string   "signature"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
