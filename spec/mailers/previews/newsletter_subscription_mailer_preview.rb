# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/newsletter_subscription_mailer
class NewsletterSubscriptionMailerPreview < ActionMailer::Preview
  def multiple_trimesters_update_available_email
    update_available_email trimesters: ["Hiver 2017 - Anciens √Čtudiants", "Hiver 2017 - Nouveaux √Čtudiants"]
  end

  def single_trimester_update_available_email
    update_available_email trimesters: ["Hiver 2017 - Anciens √Čtudiants"]
  end

  private

  def update_available_email(trimesters:)
    NewsletterSubscriptionMailer.update_available_email to: "user@example.com", trimesters: trimesters
  end
end
