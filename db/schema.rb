# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121001090418) do

  create_table "container_types", :force => true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
  end

  add_index "container_types", ["code"], :name => "index_container_types_on_code"

  create_table "containers", :force => true do |t|
    t.integer  "dossier_id"
    t.integer  "container_type_id"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "period"
  end

  add_index "containers", ["container_type_id"], :name => "index_containers_on_container_type_id"
  add_index "containers", ["dossier_id"], :name => "index_containers_on_dossier_id"
  add_index "containers", ["location_id"], :name => "index_containers_on_location_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "dossier_numbers", :force => true do |t|
    t.integer  "dossier_id"
    t.date     "to"
    t.date     "from"
    t.integer  "amount",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dossier_numbers", ["dossier_id"], :name => "index_dossier_numbers_on_dossier_id"
  add_index "dossier_numbers", ["from"], :name => "index_dossier_numbers_on_from"
  add_index "dossier_numbers", ["to"], :name => "index_dossier_numbers_on_to"

  create_table "dossiers", :force => true do |t|
    t.string   "signature"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.date     "first_document_on"
    t.text     "related_to"
    t.boolean  "delta",             :default => true,  :null => false
    t.text     "description"
    t.boolean  "internal",          :default => false
    t.string   "query"
    t.string   "sort_key"
    t.string   "sort_title"
  end

  add_index "dossiers", ["id", "signature"], :name => "index_dossiers_on_id_and_signature", :unique => true
  add_index "dossiers", ["id"], :name => "index_dossiers_on_id"
  add_index "dossiers", ["internal"], :name => "index_dossiers_on_internal"
  add_index "dossiers", ["signature"], :name => "index_dossiers_on_signature", :length => {"signature"=>20}
  add_index "dossiers", ["sort_key"], :name => "index_dossiers_on_sort_key"
  add_index "dossiers", ["sort_title"], :name => "index_dossiers_on_sort_title"
  add_index "dossiers", ["type"], :name => "index_dossiers_on_type"

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code"
    t.string   "availability"
    t.boolean  "preorder"
  end

  add_index "locations", ["code"], :name => "index_locations_on_code", :length => {"code"=>20}

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "orientation",        :default => "landscape"
    t.string   "collect_year_count"
    t.string   "columns"
    t.string   "per_page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level"
    t.boolean  "public"
    t.boolean  "years_visible",      :default => true
  end

  create_table "reservations", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "dossier_id"
    t.string   "dossier_years"
    t.string   "email"
    t.datetime "pickup"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sphinx_admins", :force => true do |t|
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from"
    t.string   "to"
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
  add_index "taggings", ["tagger_id", "tagger_type"], :name => "index_taggings_on_tagger_id_and_tagger_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :length => {"name"=>10}

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",                        :null => false
    t.integer  "item_id",                          :null => false
    t.string   "event",                            :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.boolean  "nested_model",  :default => false
    t.integer  "dossier_id"
    t.text     "container_ids"
    t.text     "number_ids"
    t.text     "keywords"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "visitor_logs", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
