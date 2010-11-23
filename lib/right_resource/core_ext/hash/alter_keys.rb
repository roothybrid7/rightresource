class Hash
  def alter_keys
    attrs = {}
    self.each_pair {|key,value| attrs[key.to_s.gsub('-', '_').to_sym] = value}
    self.clear.merge!(attrs).rehash if attrs
    self
  end
end
