class AlertSpec < RightResource::Base
  class << self
    def alert_specs_subject(id, params={})
      pair = URI.decode({:alert_specs_subject => params}.to_params).split('&').map {|l| l.split('=')}
      h = Hash[*pair.flatten]
      path = "alert_specs_subject"
      action(:post, path, h)
    end
  end
end
