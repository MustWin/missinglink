# This migration comes from missinglink (originally 20140308005724)
class AddMissinglinkSurveySchema < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string    :sm_survey_id
      t.string    :analysis_url
      t.timestamp :date_created
      t.timestamp :date_modified
      t.string    :title
      t.integer   :language_id
      t.string    :nickname
      t.boolean   :title_enabled
      t.string    :title_text

      t.timestamps
    end

    add_index :surveys, :sm_survey_id

    create_table :survey_pages do |t|
      t.string    :survey_id
      t.string    :sm_page_id
      t.text      :heading
      t.text      :sub_heading

      t.timestamps
    end

    add_index :survey_pages, :survey_id
    add_index :survey_pages, :sm_page_id

    create_table :survey_page_questions do |t|
      t.string   :survey_page_id
      t.string   :survey_question_id

      t.timestamps
    end

    add_index :survey_page_questions, :survey_page_id
    add_index :survey_page_questions, :survey_question_id

    create_table :survey_questions do |t|
      t.string    :sm_question_id
      t.text      :heading
      t.integer   :position
      t.string    :type_family
      t.string    :type_subtype

      t.timestamps
    end

    add_index :survey_questions, :sm_question_id

    create_table :survey_answers do |t|
        t.string    :sm_answer_id
        t.string    :survey_question_id
        t.integer   :position
        t.text      :text
        t.string    :answer_type
        t.boolean   :visible
        t.integer   :weight
        t.boolean   :apply_all_rows
        t.boolean   :is_answer

        t.timestamps
      end

      add_index :survey_answers, :sm_answer_id
      add_index :survey_answers, :survey_question_id

      create_table :survey_respondent_details do |t|
        t.string    :survey_id
      t.string    :sm_respondent_id
      t.timestamp :date_start
      t.timestamp :date_modified
      t.integer   :collector_id
      t.string    :collection_mode
      t.string    :custom_id
      t.string    :email
      t.string    :first_name
      t.string    :last_name
      t.string    :ip_address
      t.string    :status
      t.string    :analysis_url

      t.timestamps
    end

    add_index :survey_respondent_details, :survey_id
    add_index :survey_respondent_details, :sm_respondent_id
    add_index :survey_respondent_details, :email

    create_table :survey_responses do |t|
      t.string   :survey_respondent_detail_id
      t.string   :survey_question_id

      t.timestamps
    end

    add_index :survey_responses, :survey_respondent_detail_id
    add_index :survey_responses, :survey_question_id

    create_table :survey_response_answers do |t|
      t.string   :survey_response_id
      t.string   :row_survey_answer_id
      t.string   :col_survey_answer_id
      t.string   :col_choice_survey_answer_id
      t.text     :text

      t.timestamps
    end

    add_index :survey_response_answers, :survey_response_id
  end
end
