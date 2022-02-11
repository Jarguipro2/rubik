# frozen_string_literal: true
class Term < ApplicationRecord
  has_many :academic_degree_terms,
           -> { joins(:academic_degree).order("academic_degrees.name DESC") },
           dependent: :delete_all
  has_many :academic_degrees, through: :academic_degree_terms

  validates :year, presence: true
  validates :name, presence: true, uniqueness: { scope: [:year, :tags] }

  scope :enabled, -> { where("enabled_at IS NOT NULL").order(year: :desc, name: :asc, tags: :asc) }
end
