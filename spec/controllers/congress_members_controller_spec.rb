require 'rails_helper'

RSpec.describe CongressMembersController, type: :controller do
  let(:senator) {
    CongressMember.new(
      bioguide_id: "A0000000",
      chamber: "senate",
      state: "CA")
  }

  let(:representative) {
    CongressMember.new(
      bioguide_id: "B0000000",
      chamber: "house",
      state: "CA",
      district: "00"
    )
  }

  describe "POST /retrieve-form-elements" do
    it "should lookup the rep by BioGuide ID, then respond with the #required_params of the form" do
      form = CongressForms::WebForm.new
      required_params = [ { value: "$NAME_FIRST",
                            max_length: 100,
                            options: nil } ]

      expect(CongressMember).
        to receive(:find).
            with(senator.bioguide_id).
            and_return(senator)

      expect(CongressForms::Form).
        to receive(:find).
            with(senator.form_id).
            and_return(form)

      expect(form).
        to receive(:required_params).
            and_return(required_params)

      post :form_actions, as: :json,
           body: { bio_ids: Array(senator.bioguide_id) }.to_json

      expect(response.content_type).to eq("application/json")

      result = JSON.load(response.body)
      expect(result).to have_key(senator.bioguide_id)
      expect(result[senator.bioguide_id]).
        to include("required_actions" => required_params.map(&:deep_stringify_keys))
    end

    context "with invalid BioGuide ID" do
      it "should omit the rep from the results" do
        expect(CongressMember).to receive(:find).and_return(nil)

        post :form_actions, as: :json,
             body: { bio_ids: Array(senator.bioguide_id) }.to_json

        expect(response.content_type).to eq("application/json")
        expect(JSON.load(response.body)).to eq({})
      end
    end

    context "with missing parameters" do
      it "should respond with an error" do
        post :form_actions

        expect(response.content_type).to eq("application/json")

        result = JSON.load(response.body)
        expect(result).to include("status" => "error")
      end
    end
  end
end
