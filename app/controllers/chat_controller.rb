class ChatController < WebsocketRails::BaseController
  def initialize_session
    # controller_store[:count] = 0
    controller_store[:connections] = {}
    logger.debug "initialize_session"
  end

  def client_connected
    logger.debug "connected!: " + client_id + ":" + connection.inspect
    controller_store[:connections].store client_id, connection
    # controller_store[:count] = controller_store[:count] + 1
  end

  def client_disconnected
    logger.debug "disconnected!: " + client_id + ":" + connection.inspect
    controller_store[:connections].delete client_id
    # controller_store[:count] = controller_store[:count] - 1
  end

  def send_private_message
    controller_store[message[:target]].hhhhhhh.aaa event
    logger.debug "send_private_message"
    # options.merge! :connection => connection, :data => message
    controller_store[message[:target]].hhhhhhh event
    event = Event.new(:private_message, :connection => controller_store[message[:target]], :data => message)

    # send_message :private_message, message, :connection => controller_store[message[:target]]
  end

  def fire
    broadcast_message :water, message
  end

  def test
    connection_store[:count] = connection_store[:count] + 1
    logger.debug "!"
    Rails::Rack::Logger.logger.debug "current users: " + connection_store[:count]
  end
end