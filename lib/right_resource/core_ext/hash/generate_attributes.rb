class Hash
  def generate_attributes
    attrs = {}
    self.each_pair {|key,value| attrs[key.to_s.gsub('-', '_').to_sym] = value}
    self.clear.merge!(attrs) if attrs
    self
  end
end
