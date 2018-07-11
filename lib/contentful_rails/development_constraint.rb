module ContentfulRails
  # Constraint for ensuring development origin
  class DevelopmentConstraint
    # Returns if current request is coming from development environment or localhost
    def self.matches?(request)
      Rails.env =~ %r{development} && (request.remote_ip =~ %r{127.0.0} || request.remote_ip =~ %r{^::1$})
    end
  end
end
