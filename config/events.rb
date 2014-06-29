WebsocketRails::EventMap.describe do
  # You can use this file to map incoming events to controller actions.
  # One event can be mapped to any number of controller actions. The
  # actions will be executed in the order they were subscribed.
  #
  # Uncomment and edit the next line to handle the client connected event:
  #   subscribe :client_connected, :to => Controller, :with_method => :method_name
  #
  # Here is an example of mapping namespaced events:
  #   namespace :product do
  #     subscribe :new, :to => ProductController, :with_method => :new_product
  #   end
  # The above will handle an event triggered on the client like `product.new`.
  # Rails::Rack::Logger

  # The :client_connected method is fired automatically when a new client connects
  subscribe :client_connected, :to => ChatController, :with_method => :client_connected
  # The :client_disconnected method is fired automatically when a client disconnects
  subscribe :client_disconnected, :to => ChatController, :with_method => :client_disconnected

  namespace :websocket_rails do
    subscribe :subscribe_private, :to => AuthorizationController, :with_method => :authorize_channels
  end
  subscribe :send_private_message, :to => ChatController, :with_method => :send_private_message
  subscribe :fire, :to => ChatController, :with_method => :fire
  subscribe :test, :to => ChatController, :with_method => :test

  subscribe :ftp_hello, :to => ChatController, :with_method => :wall
  subscribe :ftp_ok, :to => ChatController, :with_method => :wall
  subscribe :update_fileinfo, :to => ChatController, :with_method => :wall
  subscribe :update_sender_candidate, :to => ChatController, :with_method => :wall
  subscribe :update_sender_offer, :to => ChatController, :with_method => :wall
  subscribe :update_receiver_candidate, :to => ChatController, :with_method => :wall
  subscribe :update_receiver_answer, :to => ChatController, :with_method => :wall
end
