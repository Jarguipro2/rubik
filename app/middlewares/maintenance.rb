# frozen_string_literal: true
class Maintenance
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    if show_maintenance_page?(request)
      [200, {}, [maintenance_page]]
    else
      @app.call(env)
    end
  end

  private

  def show_maintenance_page?(request)
    return false unless ENV["MAINTENANCE_MODE"].present?
    maintainer_ips.exclude?(request.ip)
  end

  def maintenance_page
    File.read(Rails.root.join("public", "maintenance.html"))
  end

  def maintainer_ips
    ENV.fetch("MAINTAINER_IPS", "").split(",")
  end
end
