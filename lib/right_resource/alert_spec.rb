class AlertSpec < RightResource::Base
  class << self
    def alert_specs_subject(id, params={})
      connection.post(element_path(id, :alert_specs_subject, params))
    end
  end
end
