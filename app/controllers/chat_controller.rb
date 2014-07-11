class ChatController < WebsocketRails::BaseController
  class User
    def initialize(client_id)
      @client_id = client_id
      @name = ["ワニ", "アリクイ", "アルマジロ", "アホロートル", "アナグマ", "コウモリ", "ビーバー", "水牛", "ラクダ", "カメレオン", "チーター", "シマリス", "チンチラ", "チュパカブラ", "鵜", "コヨーテ", "カラス", "ディンゴ", "恐竜", "イルカ", "アヒル", "ゾウ", "キツネ", "カエル", "キリン", "リス", "グリズリー", "ハリネズミ", "カバ", "ハイエナ", "ジャッカル", "IBEX", "イフリート", "イグアナ", "コアラ", "クラーケン", "キツネザル", "ヒョウ", "ライガー", "ラマ", "マナティー", "ミンク", "サル", "イッカク", "ニャン猫", "オランウータン", "カワウソ", "パンダ", "ペンギン", "カモノハシ", "パイソン", "カボチャ", "ウサギ", "タヌキ", "サイ", "ヒツジ", "トガリネズミ", "スカンク", "スローロリス", "リス", "亀", "セイウチ", "オオカミ", "クズリ", "ウォンバット"].sample
    end
  end

  def initialize_session
    # controller_store[:count] = 0
    controller_store[:users] = {}
    controller_store[:connections] = {}
    logger.debug "initialize_session"
  end

  def client_connected
    logger.debug "connected!: " + client_id + ":" + connection.inspect

    user = User.new client_id
    logger.debug user.inspect

    controller_store[:users].store client_id, user
    controller_store[:connections].store client_id, connection
    broadcast_message :update_users, controller_store[:users]
  end

  def client_disconnected
    logger.debug "disconnected!: " + client_id + ":" + connection.inspect
    controller_store[:users].delete client_id
    controller_store[:connections].delete client_id
    broadcast_message :update_users, controller_store[:users]
  end

  def send_private_message
    controller_store[message[:target]].hhhhhhh.aaa event
    logger.debug "send_private_message"
    # options.merge! :connection => connection, :data => message
    controller_store[message[:target]].hhhhhhh event
    event = Event.new(:private_message, :connection => controller_store[message[:target]], :data => message)

    # send_message :private_message, message, :connection => controller_store[message[:target]]
  end

  def wall
    broadcast_message event.name.to_s, message
    logger.debug event.name.to_s + " > " + message.inspect
  end

  def test
    connection_store[:count] = connection_store[:count] + 1
    logger.debug "!"
    Rails::Rack::Logger.logger.debug "current users: " + connection_store[:count]
  end
end