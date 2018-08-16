class DayinfosController < ApplicationController
  def new
    @today = Date.today.to_s.delete("-")
    @dayinfo = @employee.dayinfos.find_by_date(@today) || @employee.dayinfos.new
    if @dayinfo.start.blank?
      @today_stamp = "今日はまだ出勤していません" if @dayinfo.start.blank?
    elsif @dayinfo.end.blank?
      @today_stamp = "今日は#{@dayinfo.start.strftime("%H:%M")}に出勤しています"
    else
      @today_stamp = "今日の打刻は#{@dayinfo.start.strftime("%H:%M")} - #{@dayinfo.end.strftime("%H:%M")}でした"
    end
  end
  def put
    if @employee.present?
      today = Date.today.to_s
      dayinfo = @employee.dayinfos.find_by_date(today) || @employee.dayinfos.new(date: today)

      if params[:commit] == "出勤"
        if dayinfo.start.present?
          notice = "すでに出勤しています"
        else
          dayinfo.start = Time.current
          notice = "出勤しました"
          dayinfo.save
        end
      else #退勤
        if dayinfo.start.blank?
          notice = "まだ出勤していません"
        elsif dayinfo.end.present?
          notice = "すでに退勤しています"
        else
          dayinfo.end = Time.current
          notice = "退勤しました"
          dayinfo.save
        end
      end
      logger.debug dayinfo.errors.inspect
      redirect_to timecard_path, notice: notice
    end
  end
end