module CongressFormsApi
    class FillError < StandardError
        attr_reader :bioguide_id
        def initialize(original_message, bioguide_id)
            @bioguide_id = bioguide_id
            super("couldn't fill bioguide_id ##{bioguide_id}: #{original_message}")
        end
    end
end
