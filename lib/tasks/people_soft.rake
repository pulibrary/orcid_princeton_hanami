# frozen_string_literal: true

require 'hanami/setup'
require 'honeybadger'

namespace :people_soft do
  desc 'Saves a CSV report for PeopleSoft'
  task :report, [:filename] => [:environment] do |_, args|
    filename = args[:filename]
    raise 'Must provide a filename' if filename.nil?

    report = OrcidPrinceton::Operations::PeopleSoftReport.new
    case report.call(filename)
    in Dry::Monads::Result::Success(path)
      puts "ORCID report was created at #{path}"
    in Dry::Monads::Result::Failure(error)
      puts "ERROR:  Could not generate ORCID Report: #{error}"
    end
  end

  desc 'Saves the CSV report in the correct location for the environment'
  task cron_report: :environment do
    report = OrcidPrinceton::Operations::PeopleSoftReport.new
    output_location = Hanami.app.settings.peoplesoft_output_location
    case report.call(output_location)
    in Dry::Monads::Result::Success(path)
      puts "ORCID report was created at #{path}"
    in Dry::Monads::Result::Failure(error)
      puts "ERROR:  Could not generate ORCID Report: #{error}"
      Honeybadger.notify("ERROR:  Could not generate ORCID Report: #{error}")
    end
  end
end
