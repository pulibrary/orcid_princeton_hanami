# frozen_string_literal: true

require 'hanami/setup'
require 'honeybadger'

namespace :people_soft do
  desc 'Saves a CSV report for PeopleSoft'
  task :report, [:filename] => [:environment] do |_, args|
    filename = args[:filename]
    raise 'Must provide a filename' if filename.nil?

    report = OrcidPrinceton::Operations::PeopleSoftReport.new
    result = report.call(filename)
    if result.instance_of?(Dry::Monads::Result::Success)
      puts "ORCID report was created at #{filename}"
    else
      puts "ERROR:  Could not generate ORCID Report: #{result}"
    end
  end

  desc 'Saves the CSV report in the correct location for the environment'
  task cron_report: :environment do
    report = OrcidPrinceton::Operations::PeopleSoftReport.new
    result = report.call(Hanami.app.settings.peoplesoft_output_location)
    if result.instance_of?(Dry::Monads::Result::Success)
      puts "ORCID report was created at #{Hanami.app.settings.peoplesoft_output_location}"
    else
      puts "ERROR:  Could not generate ORCID Report: #{result}"
      Honeybadger.notify("ERROR:  Could not generate ORCID Report: #{result}")
    end
  end
end
