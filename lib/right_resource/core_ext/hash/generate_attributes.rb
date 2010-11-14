class Hash
  def generate_attributes
    attrs = {}
    self.each_pair {|key,value| attrs[key.to_s.gsub('-', '_').to_sym] = value}
    if attrs
      self.clear
      self.merge!(attrs)
    end
    self
  end
end
