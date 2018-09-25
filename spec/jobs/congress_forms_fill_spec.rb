require 'rails_helper'

RSpec.describe CongressFormsFill do
  describe "#perform(id, fields)" do
    it "should find the form by id and fill it out with fields" do
      form, id, fields = [double] * 3

      expect(CongressForms::Form).
        to receive(:find).with(id).and_return(form)

      expect(form).to receive(:fill).with(fields)

      CongressFormsFill.new.perform(id, fields)
    end
  end
end
