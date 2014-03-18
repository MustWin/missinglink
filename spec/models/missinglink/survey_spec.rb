require 'spec_helper'

module Missinglink
  describe Survey do
    let(:survey) { Survey.new }

    context "#find_or_create_by_sm_survey_id" do
      it "should create and return a new record if there is no survey with the sm_id" do
        Survey.stub(:find_by_sm_survey_id => nil)
        lambda do
          Survey.first_or_create_by_sm_survey_id(10).sm_survey_id.should == 10
        end.should change(Survey, :count).by(1)
      end

      it "should just return the existing survey if it's found" do
        Survey.stub(:find_by_sm_survey_id => survey)
        lambda do
          Survey.first_or_create_by_sm_survey_id(10).should == survey
        end.should_not change(Survey, :count)
      end
    end
  end
end
