namespace :congress do
  desc "Mark a congress member as defunct"
  task :defunct, [:bioguide] => [:environment] do |_, args|
    DefunctCongressForm.find_or_create_by(bioguide_id: args[:bioguide])
  end

  desc "No longer mark a congress member as defunct"
  task :undefunct, [:bioguide] => [:environment] do |_, args|
    DefunctCongressForm.where(bioguide_id: args[:bioguide]).destroy_all
  end
end
