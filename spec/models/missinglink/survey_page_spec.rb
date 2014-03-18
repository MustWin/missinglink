require 'spec_helper'

module Missinglink
  describe SurveyPage do
    let(:survey_page) { SurveyPage.new }

    context "#first_or_create_by_survey_details" do
      it "should create and return a new record if there is no page with the survey or sm id" do
        SurveyPage.stub(:find_by_survey_id_and_sm_page_id => nil)
        lambda do
          new_page = SurveyPage.first_or_create_by_survey_details(10, 50)
          new_page.survey_id.should == 10
          new_page.sm_page_id.should == 50
        end.should change(SurveyPage, :count).by(1)
      end

      it "should just return the existing page if it's found" do
        SurveyPage.stub(:find_by_survey_id_and_sm_page_id => survey_page)
        lambda do
          SurveyPage.first_or_create_by_survey_details(10, 50).should == survey_page
        end.should_not change(SurveyPage, :count)
      end
    end
  end
end
