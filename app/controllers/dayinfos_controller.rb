class DayinfosController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_employees_company, only: [:new, :put]

  def new
    @wday = %w(日 月 火 水 木 金 土)
    @now = Time.now
    @today = Date.today.to_s
    @dayinfo = @employee.dayinfos.find_by_date(@today) || @employee.dayinfos.new
    p @dayinfo
    if @dayinfo.start.blank?
      @today_stamp = "今日はまだ出勤していません"
    elsif @dayinfo.end.blank?
      @today_stamp = "今日は#{@dayinfo.start.strftime("%H:%M")}に出勤しています"
    else
      @today_stamp = "今日の打刻は#{@dayinfo.start.strftime("%H:%M")}" +
                     "- #{@dayinfo.end.strftime("%H:%M")}でした"
    end
  end

  def put
    if @employee.present?
      today = Date.today.to_s
      dayinfo = @employee.dayinfos.find_by_date(today) ||
                @employee.dayinfos.new(date: today)

      if params[:commit] == "出勤"
        if dayinfo.start
          alert = "すでに出勤しています"
        else
          dayinfo.start = Time.zone.now
          notice = "出勤しました"
          dayinfo.save
        end
      else #退勤
        if dayinfo.start.blank?
          alert = "まだ出勤していません"
        elsif dayinfo.end
          alert = "すでに退勤しています"
        else
          dayinfo.end = Time.zone.now
          notice = "退勤しました"
          dayinfo.save
        end
      end
      redirect_to timecard_path, notice: notice, alert: alert
    end
  end
end
