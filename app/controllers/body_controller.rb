class BodyController < ApplicationController
  before_action :authenticate_user!

  def index
    @profile = current_user.body_profile || current_user.build_body_profile

    @weight_entries = current_user.weight_entries.ordered
    @new_weight = current_user.weight_entries.build

    @measurements = current_user.body_measurements.ordered
    @new_measurement = current_user.body_measurements.build

    @period = params[:period].presence || "week"
    @measurement_key = params[:measurement].presence || "waist"
    @measurement_key = "waist" unless BodyMeasurement::MEASUREMENTS.key?(@measurement_key.to_sym)

    load_graphs
  end

  private

  def load_graphs
    case @period
    when "month" then load_month
    when "year" then load_year
    else load_week
    end
  end

  def load_week
    @graph_range = (Date.current.beginning_of_week..Date.current.end_of_week)
    @weight_labels, @weight_values = daily_series(@weight_entries, @graph_range)
    @measurement_labels, @measurement_values = measurement_series(@measurements, @measurement_key, limit: 12)
  end

  def load_month
    @graph_range = (Date.current.beginning_of_month..Date.current.end_of_month)
    @weight_labels, @weight_values = daily_series(@weight_entries, @graph_range)
    @measurement_labels, @measurement_values = measurement_series(@measurements, @measurement_key, limit: 10)
  end

  def load_year
    @graph_range = (Date.current.beginning_of_year..Date.current.end_of_year)
    @weight_labels, @weight_values = monthly_series(@weight_entries)
    @measurement_labels, @measurement_values = measurement_series(@measurements, @measurement_key, limit: 12)
  end

  def daily_series(entries, range)
    by_date = entries.for_range(range.first, range.last).to_h { |e| [ e.date, e.weight.to_f ] }
    labels = range.to_a.map { |d| d.strftime("%m/%d") }
    values = range.to_a.map { |d| by_date[d] }
    [ labels, values ]
  end

  def monthly_series(entries)
    by_month = entries.for_range(Date.current.beginning_of_year, Date.current.end_of_year)
                      .group_by { |e| e.date.month }
                      .transform_values { |group| group.map { |e| e.weight.to_f }.sum / group.size }
    labels = Date::MONTHNAMES.compact
    values = labels.map.with_index { |_name, i| by_month[i + 1]&.round(1) }
    [ labels, values ]
  end

  def measurement_series(measurements, key, limit:)
    recent = measurements.for_range(Date.current.beginning_of_year, Date.current.end_of_year)
                         .select { |m| m[key.to_sym].present? }
                         .last(limit)
    labels = recent.map { |m| m.date.strftime("%m/%d") }
    values = recent.map { |m| m[key.to_sym].to_f }
    [ labels, values ]
  end
end
