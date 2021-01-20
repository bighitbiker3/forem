# Since we must explicitly set the cookie domain in session_store before SiteConfig is available,
# this ensures we properly set the cookie to SiteConfig.app_domain at runtime.

class SetCookieDomain
  def initialize(app)
    @app = app
  end

  def call(env)
    if Rails.env.production?
      env["rack.session.options"][:domain] = ApplicationConfig["APP_DOMAIN"] || ".#{SiteConfig.app_domain}"
      Rails.log.info(env["rack.session.options"][:domain])
      Rails.log.info("Shit here")
    end
    @app.call(env)
  end
end
