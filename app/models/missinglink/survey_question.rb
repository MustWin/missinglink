module Missinglink
  class SurveyQuestion < ActiveRecord::Base
    self.table_name = "survey_questions"

    has_many :survey_page_questions
    has_many :survey_pages, through: :survey_page_questions
    has_many :survey_answers
    has_many :survey_responses
    has_many :survey_response_answers, through: :survey_responses

    def self.parse(page, hash)
      question = SurveyQuestion.first_or_create_by_sm_id(hash['question_id'])

      question.update_attributes({ heading: hash['heading'],
                                   position: hash['position'].to_i,
                                   type_family: hash['type']['family'],
                                   type_subtype: hash['type']['subtype'] })
      question.survey_pages = [page]
      question.save

      hash['answers'].each do |answer|
        SurveyAnswer.parse(question, answer)
      end

      return question.reload
    end

    def self.first_or_create_by_sm_id(sm_id)
      if question = SurveyQuestion.find_by_sm_question_id(sm_id)
        return question
      else
        return SurveyQuestion.create(sm_question_id: sm_id)
      end
    end

    # for reference, when searching, listing all possible responses is
    # logical, but it is impossible to track all survey response answers
    # that match the desired answer. therefore, we only track one
    # example, and later find all similar response answers based on the
    # question strategy
    def possible_responses(search_other = false)
      {}.tap do |hash|
        survey_response_answers.each do |sra|
          sa_row = (sra.row_survey_answer_id ? SurveyAnswer.find(sra.row_survey_answer_id) : nil)
          sa_col = (sra.col_survey_answer_id ? SurveyAnswer.find(sra.col_survey_answer_id) : nil)
          sa_col_choice = (sra.col_choice_survey_answer_id ? SurveyAnswer.find(sra.col_choice_survey_answer_id) : nil)

          case answer_strategy
          when "first_survey_response_answer_text"
            hash[sra.text] = sra.id unless (sra.text.nil? || hash[sra.text])
          when "answer_row_match_for_survey_response_answer_text"
            other_text = ((!search_other || sra.text.nil?) ? nil : "#{ (sa_row.try(:text) || "Other") }: #{ sra.text }")
            hash[sa_row.text] = sra.id unless (sa_row.nil? || hash[sa_row.text])
            hash[other_text] = sra.id unless (other_text.nil? || hash[other_text])
          when "row_column_survey_response_answers_and_text"
            main_text = "#{ sa_row.try(:text) }: #{ sa_col.try(:text) }"
            other_text = ((!search_other || sra.text.nil? || !sa_row.nil?) ? nil : "Other: #{ sra.text }")
            hash[main_text] = sra.id unless (sa_row.nil? || sa_col.nil? || hash[main_text])
            hash[other_text] = sra.id unless (other_text.nil? || hash[other_text])
          when "row_column_and_choice_survey_response_answers_and_text"
            main_text = "#{ sa_row.try(:text) }, #{ sa_col.try(:text) }: #{ sa_col_choice.try(:text) }"
            other_text = ((!search_other || sra.text.nil? || !sa_row.nil?) ? nil : "Other: #{ sra.text }")
            hash[main_text] = sra.id unless (sa_row.nil? || sa_col.nil? || sa_col_choice.nil? || hash[main_text])
            hash[other_text] = sra.id unless (other_text.nil? || hash[other_text])
          end
        end
      end
    end

    def similar_response_answers(response_answer, search_other = false)
      if search_other || answer_strategy == "first_survey_response_answer_text"
        return survey_response_answers.select { |sra| sra.text == response_answer.text }.sort
      end

      case answer_strategy
      when "answer_row_match_for_survey_response_answer_text"
        survey_response_answers.select do |sra|
          sra.row_survey_answer_id == response_answer.row_survey_answer_id
        end.sort
      when "row_column_survey_response_answers_and_text"
        survey_response_answers.select do |sra|
          sra.row_survey_answer_id == response_answer.row_survey_answer_id &&
            sra.col_survey_answer_id == response_answer.col_survey_answer_id
        end.sort
      when "row_column_and_choice_survey_response_answers_and_text"
        survey_response_answers.select do |sra|
          sra.row_survey_answer_id == response_answer.row_survey_answer_id &&
            sra.col_survey_answer_id == response_answer.col_survey_answer_id &&
            sra.col_choice_survey_answer_id == response_answer.col_choice_survey_answer_id
        end.sort
      end
    end

  private
    def answer_strategy
      Missinglink.answer_strategies[type_family][type_subtype]
    end
  end
end
