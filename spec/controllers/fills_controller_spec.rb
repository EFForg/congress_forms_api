require 'rails_helper'

RSpec.describe FillsController, type: :controller do
  let(:senator) {
    CongressMember.new(
      bioguide_id: "A0000000",
      chamber: "senate",
      state: "CA")
  }

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
        post :create, as: :json,
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
          post :create, as: :json, body: params.to_json

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

        set = CongressFormsFill.set

        expect(CongressFormsFill).
          to receive(:set).and_return(set)

        expect(set).
          to receive(:perform_later).
              with(senator.congress_forms_id, fields)

        post :create, as: :json,
             body: { bio_id: senator.bioguide_id, fields: fields }.to_json
      end
    end
  end
end
