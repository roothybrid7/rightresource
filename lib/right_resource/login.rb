class Login
  def get(resource={})
    
  end
  def init_resources(rs_vars)
    Server.set_auth(rs_vars[:username], rs_vars[:password], rs_vars[:account])
    ServerArray.set_auth(rs_vars[:username], rs_vars[:password], rs_vars[:account])
    Deployment.set_auth(rs_vars[:username], rs_vars[:password], rs_vars[:account])
  rescue => e
    $logger.warn("FAILED: RightAPI login\n" + e)
    exit 0
  else
    $logger.info("SUCCESS: RightAPI login successfully.")
    return true
  end
end
