class AlertSpec < RightResource::Base
  class << self
    def alert_specs_subject(id, params={})
      connection.post(element_path(id, {:alert_specs_subject => nil}, params))
    end
  end

  def alert_specs_subject(id, params={})
    connection.post(element_path({:alert_specs_subject => nil}, params))
  end
end
