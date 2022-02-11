# frozen_string_literal: true
require "rails_helper"

describe EtsPdf::Etl::Transform::TermUpdater do
  describe "#execute" do
    context "for an invalid term handle" do
      subject(:term_updater) { described_class.new(2015, term) }
      let(:term) { { "patate" => {} } }

      it "throws and error" do
        expect { term_updater.execute }.to raise_error('Invalid term handle "patate"')
      end
    end

    context "for an invalid tag" do
      subject(:term_updater) { described_class.new(2014, term) }
      let(:term) { { "automne" => { "nope" => :data } } }

      it "throws and error" do
        expect { term_updater.execute }.to raise_error('Invalid bachelor type "nope"')
      end
    end

    context "for valid term handles and tags" do
      subject(:term_updater) { described_class.new(2016, term) }
      let(:term) do
        {
          "automne" => {
            "anciens" => :data_1,
            "nouveaux" => :data_2,
          },
          "ete" => {
            "nouveaux" => :data_3,
          },
          "hiver" => {
            "anciens" => :data_4,
            "tous" => :data_5,
          },
        }
      end
      let(:updaters_attributes) do
        {
          data_1: { year: 2016, name: "Automne", tags: "Anciens Étudiants" },
          data_2: { year: 2016, name: "Automne", tags: "Nouveaux Étudiants" },
          data_3: { year: 2016, name: "Été", tags: "Nouveaux Étudiants" },
          data_4: { year: 2016, name: "Hiver", tags: "Anciens Étudiants" },
          data_5: { year: 2016, name: "Hiver", tags: nil },
        }
      end
      let(:bachelor_updaters) do
        updaters_attributes.collect do |bachelors_data, updater_attributes|
          bachelor_updater = instance_double(EtsPdf::Etl::Transform::BachelorUpdater)
          term_record = instance_with_attributes(updater_attributes)

          allow(EtsPdf::Etl::Transform::BachelorUpdater)
            .to receive(:new).with(term_record, bachelors_data).and_return(bachelor_updater)

          bachelor_updater
        end
      end
      before do
        bachelor_updaters.each do |bachelor_updater|
          allow(bachelor_updater).to receive(:execute)
        end
      end

      context "when the terms do not exist" do
        it "creates the terms" do
          term_updater.execute

          updaters_attributes.values.each do |updater_attributes|
            expect(Term.find_by(**updater_attributes)).to be_present
          end
        end
      end

      context "when the terms do exist" do
        before do
          updaters_attributes.values.each do |updater_attributes|
            Term.create!(**updater_attributes)
          end
        end

        it "does not create new terms" do
          expect { term_updater.execute }.not_to change { Term.count }
        end
      end
    end
  end
end
