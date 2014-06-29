class AuthorizationController < WebsocketRails::BaseController
  def authorize_channels
    Rails::Rack::Logger.logger.debug "user!"
    # logger.debug "user come " + current_user
    accept_channel current_user
  end

  def client_connected
    logger.debug "connected: " + client_id + ":" + connection.inspect
    controller_store[:count] = controller_store[:count] + 1
  end

  def client_disconnected
    logger.debug "disconnected: " + client_id + ":" + connection.inspect
    controller_store[:count] = controller_store[:count] - 1
  end
end