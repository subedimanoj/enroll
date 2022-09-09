# RAILS_ENV=production bundle exec rake migrations:add_existing_family_member_to_coverage_household
# To add the primary person to the coverage household, use primary hbx id as dependent hbx id
# Interactive rake that takes input from the user to be completed

require File.join(Rails.root, "app", "data_migrations","rake", "add_existing_family_member_to_coverage_household")

namespace :migrations do
  desc "Add existing family member to coverage household"
  AddExistingFamilyMemberToCoverageHousehold.define_task :add_existing_family_member_to_coverage_household => :environment
end
