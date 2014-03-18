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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140308005724) do

  create_table "survey_answers", force: true do |t|
    t.integer  "sm_answer_id"
    t.integer  "survey_question_id"
    t.integer  "position"
    t.text     "text"
    t.string   "answer_type"
    t.boolean  "visible"
    t.integer  "weight"
    t.boolean  "apply_all_rows"
    t.boolean  "is_answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_answers", ["sm_answer_id"], name: "index_survey_answers_on_sm_answer_id"
  add_index "survey_answers", ["survey_question_id"], name: "index_survey_answers_on_survey_question_id"

  create_table "survey_page_questions", force: true do |t|
    t.integer  "survey_page_id"
    t.integer  "survey_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_page_questions", ["survey_page_id"], name: "index_survey_page_questions_on_survey_page_id"
  add_index "survey_page_questions", ["survey_question_id"], name: "index_survey_page_questions_on_survey_question_id"

  create_table "survey_pages", force: true do |t|
    t.integer  "survey_id"
    t.integer  "sm_page_id"
    t.text     "heading"
    t.text     "sub_heading"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_pages", ["sm_page_id"], name: "index_survey_pages_on_sm_page_id"
  add_index "survey_pages", ["survey_id"], name: "index_survey_pages_on_survey_id"

  create_table "survey_questions", force: true do |t|
    t.integer  "sm_question_id"
    t.text     "heading"
    t.integer  "position"
    t.string   "type_family"
    t.string   "type_subtype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_questions", ["sm_question_id"], name: "index_survey_questions_on_sm_question_id"

  create_table "survey_respondent_details", force: true do |t|
    t.integer  "survey_id"
    t.integer  "sm_respondent_id"
    t.datetime "date_start"
    t.datetime "date_modified"
    t.integer  "collector_id"
    t.string   "collection_mode"
    t.string   "custom_id"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "ip_address"
    t.string   "status"
    t.string   "analysis_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_respondent_details", ["email"], name: "index_survey_respondent_details_on_email"
  add_index "survey_respondent_details", ["sm_respondent_id"], name: "index_survey_respondent_details_on_sm_respondent_id"
  add_index "survey_respondent_details", ["survey_id"], name: "index_survey_respondent_details_on_survey_id"

  create_table "survey_response_answers", force: true do |t|
    t.integer  "survey_response_id"
    t.integer  "row_survey_answer_id"
    t.integer  "col_survey_answer_id"
    t.integer  "col_choice_survey_answer_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_response_answers", ["survey_response_id"], name: "index_survey_response_answers_on_survey_response_id"

  create_table "survey_responses", force: true do |t|
    t.integer  "survey_respondent_detail_id"
    t.integer  "survey_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "survey_responses", ["survey_question_id"], name: "index_survey_responses_on_survey_question_id"
  add_index "survey_responses", ["survey_respondent_detail_id"], name: "index_survey_responses_on_survey_respondent_detail_id"

  create_table "surveys", force: true do |t|
    t.integer  "sm_survey_id"
    t.string   "analysis_url"
    t.datetime "date_created"
    t.datetime "date_modified"
    t.string   "title"
    t.integer  "language_id"
    t.string   "nickname"
    t.boolean  "title_enabled"
    t.string   "title_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "surveys", ["sm_survey_id"], name: "index_surveys_on_sm_survey_id"

end
