# frozen_string_literal: true
require "rails_helper"

describe EtsPdf::Etl::Transform do
  it_behaves_like "Pipeline"

  describe "#execute" do
    subject(:transform_etl) { described_class.new(terms) }
    let(:terms) { { 2016 => :arguments, 2015 => :more_arguments } }
    let(:term_updaters) { terms.map { instance_double(EtsPdf::Etl::Transform::TermUpdater) } }
    before do
      term_updaters.zip(terms).each do |term_updater, arguments|
        allow(EtsPdf::Etl::Transform::TermUpdater).to receive(:new).with(*arguments).and_return(term_updater)
      end
    end

    it "updates the database for every term passed in" do
      term_updaters.each { |term_updater| allow(term_updater).to receive(:execute) }

      transform_etl.execute
    end
  end
end
