# frozen_string_literal: true

require 'csv'

module OrcidPrinceton
  module Operations
    # write a report for peoplesoft in the expected location
    #  This is run daily via cron
    class PeopleSoftReport < OrcidPrinceton::Operation
      include Deps['repos.user_repo']

      def call(filename, rows = nil)
        rows = step load_rows(rows)

        step create_report(filename, rows)
      end

      private

      def load_rows(rows)
        if rows.blank?
          rows = []
          user_repo.user_with_roles_and_tokens.each do |user|
            next if user.valid_token.nil?

            rows << OrcidPrinceton::Structs::PeopleSoftRow.new_from_user(user)
          end
        end
        Success(rows)
      end

      def create_report(filename, data)
        CSV.open(filename, 'w') do |csv|
          csv << ['University ID', 'Net ID', 'Full Name', 'Identifier Type', 'ORCID iD', 'Date Effective',
                  'Effective Until']
          data.each do |row|
            csv << [row.university_id, row.netid, row.full_name, row.row_type, row.orcid, row.effective_from,
                    row.effective_until]
          end
        end
        Success(filename)
      end
    end
  end
end
