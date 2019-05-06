module DashboardHelper
  def percentage(number)
    number ||= 0
    number_to_percentage(number * 100, :precision => 0)
  end
end
