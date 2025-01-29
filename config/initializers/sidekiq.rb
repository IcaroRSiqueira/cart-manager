# frozen_string_literal: true

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], timeout: 5.0 }
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('../schedule.yml', __dir__))
    Sidekiq::Scheduler.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], timeout: 5.0 }
end
