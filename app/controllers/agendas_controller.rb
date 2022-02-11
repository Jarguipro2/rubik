# frozen_string_literal: true
class AgendasController < ApplicationController
  include AgendaEagerLoading
  include BrowserCaching

  before_action :invalidate_browser_cache
  # before_action :assign_academic_degree_term,
  #               :instantiate_agenda, only: [:new, :create]
  before_action :assign_term,
                :instantiate_agenda, only: [:new, :create]
  before_action :find_agenda, only: [:edit, :update]
  # before_action :filter_agenda
  before_action :ensure_not_processing, only: [:edit, :update]
  before_action :eager_load_courses
  before_action :assign_attributes, only: [:create, :update]
  before_action :save, only: [:create, :update]

  delegate :step, to: :agenda_creation_process
  helper_method :step

  def new
    render step
  end

  def edit
    render step
  end

  def create; end

  def update; end

  private

  # def assign_academic_degree_term
  #   @academic_degree_term = AcademicDegreeTerm.enabled.find(params[:academic_degree_term_id])
  # end

  # def assign_academic_degree
  #   @academic_degree = AcademicDegree.find(params[:academic_degree_id])
  # end

  def assign_term
    @term = Term.enabled.find(params[:term_id])
  end

  # def instantiate_agenda
  #   @agenda = @academic_degree_term.agendas.new
  # end

  def instantiate_agenda
    @agenda = @term.agendas.new
  end

  # def filter_agenda
  #   @agenda = AgendaFilterDecorator.new(object: @agenda, params: params)
  # end

  def agenda_params
    params.require(:agenda).permit(
      :courses_per_schedule,
      :filter_groups,
      agenda_term_tags_attributes: [:_destroy, :id, :term_tag_id],
      courses_attributes: [:_destroy, :academic_degree_term_course_id, :id, :mandatory, { group_numbers: [] }],
      leaves_attributes: [:_destroy, :ends_at, :starts_at]
    )
  end

  def agenda_token
    params.require(:token)
  end

  def assign_attributes
    @agenda.assign_attributes(agenda_params)
  end

  def agenda_creation_process
    @agenda_creation_process ||= AgendaCreationProcess.new(agenda: @agenda, step: params[:step])
  end

  def save
    agenda_creation_process.save ? redirect_to(agenda_creation_process.path) : render(step)
  end

  def ensure_not_processing
    redirect_to(processing_agenda_schedules_path(@agenda)) if @agenda.processing?
  end
end
