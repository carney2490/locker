def sort_campaigns(campaigns, date)
	active_campaigns = []
  future_campaigns = []
  past_campaigns = []
  campaigns.each do |campaign|
    end_date = Date.parse(campaign['end_date'])
    start_date = Date.parse(campaign['start_date'])
    if date >= start_date && date <= end_date
      active_campaigns << campaign
    elsif date > end_date
      past_campaigns << campaign
    else
      future_campaigns << campaign
    end
  end
  {active_campaigns: active_campaigns, past_campaigns: past_campaigns, future_campaigns: future_campaigns}
end