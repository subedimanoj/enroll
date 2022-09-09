require File.join(Rails.root, "lib/mongoid_migration_task")

class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end

    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end

    def bold;           "\e[1m#{self}\e[22m" end
    def italic;         "\e[3m#{self}\e[23m" end
    def underline;      "\e[4m#{self}\e[24m" end
    def blink;          "\e[5m#{self}\e[25m" end
    def reverse_color;  "\e[7m#{self}\e[27m" end
end

class AddExistingFamilyMemberToCoverageHousehold < MongoidMigrationTask
    def migrate
        begin
            print "Enter Primary Person's HBX ID: ".cyan
            primary_hix_entry = gets
            primary_hix = primary_hix_entry.chomp

            print "Enter Dependent's HBX ID: ".cyan
            dep_hix_entry = gets
            dep_hix = dep_hix_entry.chomp

            # Tests for person account
            unless Person.by_hbx_id(primary_hix).first.present?
                puts "No person account found for Primary HBX ID #{primary_hix}. Please review and run again.".red.bold
                return
            end
            primary_person = Person.by_hbx_id(primary_hix).first

            # Tests for primary family account
            unless primary_person.primary_family.present?
                puts "Primary Family missing for Primary Person's HBX ID #{primary_hix}. Please review and run again.".red.bold
                return
            end
            primary_family = primary_person.primary_family

            # Tests for dependent account
            unless Person.by_hbx_id(dep_hix).first.present?
                puts "No person account found for Dependent HBX ID #{dep_hix}. Please review and run again.".red.bold
                return
            end
            dep_person = Person.by_hbx_id(dep_hix).first

            # Verifies the dependent is an active family member
            active_family_members = primary_family.family_members.where(:person_id => dep_person.id, :is_active => true)

            if active_family_members.count == 1
                family_member =  active_family_members.first
                household     =  primary_family.active_household

                # Actual addition takes place
                household.add_household_coverage_member(family_member)
                household.coverage_households.each do |coverage_household|
                    coverage_household.save unless coverage_household.persisted?
                    puts "\n\nFamily Member with HBX ID #{dep_hix} successfully added to Coverage Household. Thank you.\n\n".green.bold
                end
            else
                puts "\n\nNo dependents found with HBX ID #{dep_hix}. Please review and run again.".red.bold
            end
        rescue => e
            puts "\n\nError Encountered: #{e}".red.bold
        end
    end
end
