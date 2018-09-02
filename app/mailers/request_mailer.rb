class RequestMailer < ApplicationMailer
  def request_accepted_mail(email, admin_comment)
    @admin_comment = admin_comment
    mail to: email, subject: "申請が承認されました",
         layout: "request_accepted_mail"
  end
  def request_rejected_mail(email, admin_comment)
    @admin_comment = admin_comment
    mail to: email, subject: "申請は棄却されました",
         layout: "request_rejected_mail"
  end
end
