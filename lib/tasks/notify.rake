# Tasks for sending notifications
namespace :kp do

  desc "Send reminder to companions for groups on upcoming occasions"
  task(notify_occasion_reminder: :environment) do
    NotifyOccasionReminder.new(Date.today, APP_CONFIG[:occasion_reminder_days]).run
  end

  desc "Sends a link to occasions' evaluation forms to the companion"
  task(send_answer_forms: :environment) do
    SendAnswerForms.new(Date.today, APP_CONFIG[:evaluation_form][:activation_days]).run
  end

  desc "Reminds a companion to fill in the evaluation form"
  task(remind_answer_form: :environment) do
    RemindAnswerForm.new(Date.today, APP_CONFIG[:evaluation_form][:reminder_days]).run
  end

  desc "Sends a notification for ticket release"
  task(notify_ticket_release: :environment) do
    NotifyTicketRelease.new.run
  end

  desc "Send a reminder that tickets are still available to alloted recipients"
  task(notify_available_tickets: :environment) do
    NotifyAvailableTickets.new(Date.today, APP_CONFIG[:ticket_state][:reminder_weeks].to_i).run
  end

end

