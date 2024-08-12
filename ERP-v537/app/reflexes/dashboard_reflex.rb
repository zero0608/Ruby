class DashboardReflex < ApplicationReflex
  def chart_set_week
    @chart_label = "This Week"
    @chart_date_begin = Time.now.at_beginning_of_week
    @chart_date_end = Time.now.at_end_of_week
  end
  def chart_set_month
    @chart_label = "This Month"
    @chart_date_begin = Time.now.at_beginning_of_month
    @chart_date_end = Time.now.at_end_of_month
  end
  def chart_set_quarter
    @chart_label = "This Quarter"
    @chart_date_begin = Time.now.at_beginning_of_quarter
    @chart_date_end = Time.now.at_end_of_quarter
  end
  def chart_set_year
    @chart_label = "This Year"
    @chart_date_begin = Time.now.at_beginning_of_year
    @chart_date_end = Time.now.at_end_of_year
  end
  def chart_set_begin_date
    @chart_label = "Custom Range"
    @chart_date_begin = element[:value]
  end
  def chart_set_end_date
    @chart_label = "Custom Range"
    @chart_date_end = element[:value]
  end
end