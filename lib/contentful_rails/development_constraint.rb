class ContentfulRails::DevelopmentConstraint
  def self.matches?(request)
    Rails.env =~ %r{development} && (request.remote_ip =~ %r{127.0.0} || request.remote_ip =~ %r{^::1$})
  end
end