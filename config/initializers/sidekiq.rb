require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    schedule_file = "config/sidekiq.yml"

    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)[:scheduler]
      Sidekiq.schedule = schedule if schedule
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end
