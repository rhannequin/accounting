# frozen_string_literal: true

class FrenchDateParser
  def initialize(str)
    @french_date = str
  end

  def parse
    return Time.zone.today if french_date == "Aujourd'hui"
    return Time.zone.yesterday if french_date == "Hier"

    remove_day_name!
    replace_month_name!
    Date.parse(french_date.strip)
  end

  private

  attr_reader :french_date

  def remove_day_name!
    french_date.remove!("lundi")
    french_date.remove!("mardi")
    french_date.remove!("mercredi")
    french_date.remove!("jeudi")
    french_date.remove!("vendredi")
    french_date.remove!("samedi")
    french_date.remove!("dimanche")
    french_date
  end

  def replace_month_name!
    french_date.gsub!("janv.", "january")
    french_date.gsub!("févr.", "february")
    french_date.gsub!("mars", "march")
    french_date.gsub!("avr.", "april")
    french_date.gsub!("mai", "may")
    french_date.gsub!("juin", "june")
    french_date.gsub!("juil.", "july")
    french_date.gsub!("août", "august")
    french_date.gsub!("sept.", "september")
    french_date.gsub!("oct.", "october")
    french_date.gsub!("nov.", "november")
    french_date.gsub!("déc.", "december")
    french_date
  end
end
