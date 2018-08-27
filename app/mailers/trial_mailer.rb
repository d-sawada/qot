class TrialMailer < ApplicationMailer
  def start_trial_mail(admin)
    @admin = admin
    mail to: @admin.email, subject: "【勤怠管理システムQueen of Time】アカウント発行のご案内", layout: "start_trial_mail"
  end
end
