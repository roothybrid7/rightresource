class S3Bucket < RightResource::Base
  class << self
    undef :update
  end
  undef :update
end
