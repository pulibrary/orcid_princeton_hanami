# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OrcidPrinceton::Operations::PeopleSoftReport, type: :operation do
  let(:file_name) { "./report#{Random.rand(10_000)}.csv" }
  subject(:row1) do
    OrcidPrinceton::Structs::PeopleSoftRow.new(university_id: 'id', netid: 'abc123', full_name: 'Jane Doe',
                                               orcid: 'orcid', effective_from: 'date', effective_until: 'date2')
  end
  subject(:row2) do
    OrcidPrinceton::Structs::PeopleSoftRow.new(university_id: 'id2', netid: 'def456', full_name: 'Sally Smith',
                                               orcid: 'orcid2', effective_from: 'date', effective_until: 'date2')
  end
  let(:valid_data) { [row1, row2] }

  it 'includes only valid users' do
    user_valid = Factory[:user_with_orcid_and_token, university_id: '111345']
    user_valid2 = Factory[:user_with_orcid_and_token, university_id: '67890']
    user_invalid = Factory[:user_with_expired_token, university_id: '223344']
    report = described_class.new
    result = report.call(file_name)
    expect(result).to be_a Dry::Monads::Result::Success
    expect(File.exist?(file_name)).to be true
    lines = File.readlines(file_name)
    expect(lines.first).to eq "University ID,Net ID,Full Name,Identifier Type,ORCID iD,Date Effective,Effective Until\n"
    expect(lines.index { |row| row.include?(user_invalid.uid) }).to be nil
    expect(lines.index { |row| row.include?(user_valid.uid) }).not_to be nil
    expect(lines.index { |row| row.include?(user_valid2.uid) }).not_to be nil
  end

  it 'it saves the report to a file with the correct header' do
    report = described_class.new
    result = report.call(file_name, valid_data)
    expect(result).to be_a Dry::Monads::Result::Success
    expect(File.exist?(file_name)).to be true
    lines = File.readlines(file_name)
    expect(lines.first).to eq "University ID,Net ID,Full Name,Identifier Type,ORCID iD,Date Effective,Effective Until\n"
    expect(lines[1]).to eq "id,abc123,Jane Doe,ORC,orcid,date,date2\n"
    expect(lines[2]).to eq "id2,def456,Sally Smith,ORC,orcid2,date,date2\n"
    File.delete(file_name)
  end
end
