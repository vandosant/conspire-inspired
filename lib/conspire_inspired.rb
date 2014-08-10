require 'active_support/core_ext/date'

class ConspireInspired
  attr_reader :emails

  def initialize(path)
    @emails = get_emails(path)

  end

  def relationships(email_address)
    result = {}
    statistics = {}
    @emails.each do |email|
      from_index = email.index("From: ")
      from_email = email[(from_index)+6..-1].split("\r").first
      to_index = email.index("To: ")
      to_email = email[(to_index+4)..-1].split("\r").first
      date_index = email.index("Date: ")
      email_date_as_string = email[(date_index+6)..-1].split("\r").first
      email_date = Date.parse(email_date_as_string)
      if from_email == email_address
        statistics[to_email] ||= {}
        statistics[to_email]["sent"] ||= 0
        statistics[to_email]["sent"] += 1
        statistics[to_email]["last_active"] ||= email_date
        if email_date > statistics[to_email]["last_active"]
          statistics[to_email]["last_active"] = email_date
        end
      elsif to_email == email_address
        statistics[from_email] ||= {}
        statistics[from_email]["received"] ||= 0
        statistics[from_email]["received"] += 1
        statistics[from_email]["last_active"] ||= email_date
        if email_date > statistics[from_email]["last_active"]
          statistics[from_email]["last_active"] = email_date
        end
      end
    end
    statistics.each do |email, stats|
      response_rate = stats["received"].to_f/stats["sent"].to_f
      if stats["sent"] >= 3 && response_rate >= 0.66 && stats["last_active"] > Date.today.weeks_ago(2)
        result[email] = "Current Friend"
      elsif stats["sent"] >= 3 && response_rate >= 0.66
        result[email] = "Old Friend"
      end
    end
    result
  end


  private

  def get_emails(path)
    result = []
    this_path = path + "/*.eml"
    Dir.glob(this_path).each do |file|
      result << File.read(file)
    end
    result
  end
end