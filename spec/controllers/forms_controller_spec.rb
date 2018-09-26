require 'rails_helper'

RSpec.describe FormsController, type: :controller do
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
      form = CongressForms::Form.new
      required_params = [ { value: "$NAME_FIRST",
                            max_length: 100,
                            options: nil } ]

      expect(CongressMember).
        to receive(:find).
            with(senator.bioguide_id).
            and_return(senator)

      expect(CongressForms::Form).
        to receive(:find).
            with(senator.congress_forms_id).
            and_return(form)

      expect(form).
        to receive(:required_params).
            and_return(required_params)

      post :elements, as: :json,
           body: { bio_ids: Array(senator.bioguide_id) }.to_json

      expect(response.content_type).to eq("application/json")

      result = JSON.load(response.body)
      expect(result).to eq(senator.bioguide_id => {
                             "required_actions" => required_params.map(&:deep_stringify_keys)
                           }
                          )
    end

    context "with invalid BioGuide ID" do
      it "should omit the rep from the results" do
        expect(CongressMember).to receive(:find).and_return(nil)

        post :elements, as: :json,
             body: { bio_ids: Array(senator.bioguide_id) }.to_json

        expect(response.content_type).to eq("application/json")
        expect(JSON.load(response.body)).to eq({})
      end
    end

    context "with missing parameters" do
      it "should respond with an error" do
        post :elements

        expect(response.content_type).to eq("application/json")

        result = JSON.load(response.body)
        expect(result).to include("status" => "error")
      end
    end
  end

  describe "POST /fill-out-form" do
    it "should #fill the rep's form with the submitted values" do
      expect(CongressMember).
        to receive(:find).
            with(senator.bioguide_id).
            and_return(senator)

      form = CongressForms::Form.new
      expect(CongressForms::Form).
        to receive(:find).
            with(senator.congress_forms_id).
            and_return(form)

      fields = { "$NAME_FIRST" => "test test test" }
      expect(form).to receive(:fill).
                       with(fields, anything).
                       and_return(true)

      expect {
        post :fill, as: :json,
             body: { bio_id: senator.bioguide_id, fields: fields }.to_json
      }.to change{ Fill.where(bioguide_id: senator.bioguide_id).success.count }.by(1)
    end

    context "required fields are missing" do
      pending "it should respond with an error"
    end

    context "rep can't be found" do
      pending "it should respond with an error"
    end

    context "with missing parameters" do
      it "should respond with an error" do
        [{}, { "bio_id" => senator.bioguide_id }, { "fields" => {} }].each do |params|
          post :fill, as: :json, body: params.to_json

          expect(response.content_type).to eq("application/json")

          result = JSON.load(response.body)
          expect(result).to include("status" => "error")
        end
      end
    end

    context "form.fill fails" do
      it "should enqueue a delayed CongressFormsFill job" do
        expect(CongressMember).
          to receive(:find).
              with(senator.bioguide_id).
              and_return(senator)

        form = CongressForms::Form.new
        expect(CongressForms::Form).
          to receive(:find).
              with(senator.congress_forms_id).
              and_return(form)

        expect(form).
          to receive(:fill).
              and_raise(CongressForms::Error.new)

        fields = { "$NAME_FIRST" => "test test" }

        expect(CongressFormsFill).
          to receive(:perform_later).
              with(senator.congress_forms_id, fields)

        post :fill, as: :json,
             body: { bio_id: senator.bioguide_id, fields: fields }.to_json
      end
    end
  end
end
