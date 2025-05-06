require 'rails_helper'

RSpec.describe FillsController, type: :controller do
  let(:senator) {
    CongressMember.new(
      name: "Soandso",
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

      form = CongressForms::WebForm.new
      expect(CongressForms::Form).
        to receive(:find).
            with(senator.form_id).
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

          expect(response.content_type).to include("application/json")

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

        form = CongressForms::WebForm.new
        expect(CongressForms::Form).
          to receive(:find).
              with(senator.form_id).
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
              with(senator.form_id, fields)

        post :create, as: :json,
             body: { bio_id: senator.bioguide_id, fields: fields }.to_json
      end
    end
  end


  describe "GET /successful-fills-by-date" do
    before do
      10.times do |n|
        Fill.create(
          status: "success",
          bioguide_id: "A0000000",
          created_at: Time.zone.now - n.days
        )
      end
    end

    it "should return all dates" do
      get :report_by_date, as: :json,
        params: { debug_key: ENV["DEBUG_KEY"] }
      expect(JSON.parse(response.body).length).to eq 10
    end

    it "should accept a date range" do
      get :report_by_date, as: :json,
        params: { date_start: Date.today - 7.days,
                  date_end: Date.today - 1.days,
                  debug_key: ENV["DEBUG_KEY"]}
      expect(JSON.parse(response.body).length).to eq 8
    end

    it "should group by hour when dates match" do
      get :report_by_date, as: :json,
        params: { date_start: Date.today,
                  date_end: Date.today,
                  debug_key: ENV["DEBUG_KEY"]}
      expect(JSON.parse(response.body).length).to eq 25
    end
  end
end
