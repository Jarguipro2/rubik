# frozen_string_literal: true
class EtsPdf::Etl::Transform::TermUpdater
  TERM_HANDLES = {
    "automne" => "Automne",
    "ete" => "Été",
    "hiver" => "Hiver",
  }.freeze
  TERM_TAGS = {
    "anciens" => "Anciens Étudiants",
    "nouveaux" => "Nouveaux Étudiants",
    "tous" => nil,
  }.freeze

  def initialize(year, term)
    @year = year
    @term = term
  end

  def execute
    @term.each do |term_handle, bachelor_types|
      term_name = TERM_HANDLES[term_handle] || raise("Invalid term handle \"#{term_handle}\"")
      for_each_bachelor_type(term_name, bachelor_types)
    end
  end

  private

  def for_each_bachelor_type(term_name, bachelor_types)
    bachelor_types.each do |bachelor_type, bachelors_data|
      term_tags =
        TERM_TAGS.key?(bachelor_type) ? TERM_TAGS[bachelor_type] : raise("Invalid bachelor type \"#{bachelor_type}\"")
      # term = Term.where(year: @year, name: term_name, tags: term_tags).first_or_create!
      term = Term.where(year: @year, name: term_name).first_or_create!
      term_tag =
        if term_tags.nil?
          nil
        else
          term.term_tags.where(label: term_tags, scope: :group).first_or_create!
        end
      # term_tag = Tag.where(label: term_tags, scope: :group, taggable_type: Term, taggable_id: term.id).first_or_create!

      EtsPdf::Etl::Transform::BachelorUpdater.new(term, term_tag, bachelors_data).execute
    end
  end
end
