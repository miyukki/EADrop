# ITS A MAGIC
window.RTCPeerConnection = window.webkitRTCPeerConnection ||
                           window.webkitPeerConnection00 ||
                           window.mozRTCPeerConnection ||
                           window.RTCPeerConnection

window.RTCSessionDescription = window.mozRTCSessionDescription ||
                               window.RTCSessionDescription

window.RTCIceCandidate = window.mozRTCIceCandidate ||
                         window.RTCIceCandidate


peerConnectionConfig =
  iceServers: [
    url: "stun:stun.l.google.com:19302"
  ]

peerDataConnectionConfig =
  optional: [
#    RtpDataChannels: true
  ]

#
# FileSender
#
# update_sender_candidate
# update_sender_offer
class FileSender
  constructor: (@target_client_id, @file, @websocket) ->
    @file_charSlice = 10000
    @file_data = null
    @file_dataSent = 0
    ##

    @websocket.bind "update_receiver_candidate", @updateReceiverCandidate
    @websocket.bind "update_receiver_answer", @updateReceiverAnswer
    @sendWebSocketMessage "update_fileinfo", file

    @connection = new RTCPeerConnection peerConnectionConfig, peerDataConnectionConfig
    @connection.onnegotiationneeded = @onRTCNegotiationNeeded
    @connection.onicecandidate = @onRTCIceCandidate
    @connection.ondatachannel = @onRTCDataChannel

    @attachDataChannel @connection.createDataChannel "channel", reliable: true

    @connection.createOffer (description) =>
      console.log "OnCreateOffer 1"
      @connection.setLocalDescription description, =>
        console.log "OnSetLocalDescription 2"
        @sendWebSocketMessage "update_sender_offer", description

  updateReceiverCandidate: (data) =>
    return if data.target isnt @getOwnClientId()
    @connection.addIceCandidate new RTCIceCandidate(data.body)

  updateReceiverAnswer: (data) =>
    return if data.target isnt @getOwnClientId()
    @connection.setRemoteDescription new RTCSessionDescription(data.body)

  attachDataChannel: (@channel) =>
    window.dc = @channel
    @channel.onopen = @onRTCChannelOpen
    @channel.onmessage = @onRTCChannelMessage

  getOwnClientId: ->
    @websocket._conn.connection_id

  sendWebSocketMessage: (event_name, body) ->
    message = sender: @getOwnClientId(), target: @target_client_id, body: body
    @websocket.trigger event_name, message

  onRTCIceCandidate: (event) =>
    console.log "onRTCIceCandidate"
    if event.candidate
      @sendWebSocketMessage "update_sender_candidate", event.candidate

  onRTCDataChannel: (event) =>
    console.log "onRTCDataChannel"
    @attachDataChannel event.channel

  onRTCNegotiationNeeded: (event) =>
    console.log "onRTCNegotiationNeeded"

  onRTCChannelOpen: =>
    console.log "onRTCChannelOpen"
    @sendFile()

  onRTCChannelMessage: (message) =>
    console.log "onRTCChannelMessage"
    @sendFilePart()

  sendRTCMessage: (event) ->
    @channel.send event

  ## FILES

  sendFile: ->
    reader = new FileReader
    reader.onload = (event) =>
      @file_data = event.target.result
      $("#loader_outer").fadeIn(500) if not $('#loader_outer').is(':visible')
      @sendFilePart()
    reader.readAsDataURL @file

  sendFilePart: ->
    if @file_dataSent >= @file_data.length
      $("#loader_outer").fadeOut(1000)
      console.log "送信完了"
      @sendRTCMessage "\n"
      return

    slideEndIndex = @file_dataSent + @file_charSlice
    if slideEndIndex > @file_data.length
      slideEndIndex = @file_data.length
    @sendRTCMessage @file_data.slice(@file_dataSent, slideEndIndex)
    @file_dataSent = slideEndIndex

    percent = @file_dataSent/@file_data.length
    $("#loader").css("width", percent*100 + "%")

#
# FileReceiver
#
# update_sender_candidate
# update_sender_offer
class FileReceiver
  constructor: (@target_client_id, @websocket, @isDownloadMode = true) ->
    @websocket.bind "update_sender_candidate", @updateSenderCandidate
    @websocket.bind "update_sender_offer", @updateSenderOffer
    @websocket.bind "update_fileinfo", @updateFileinfo

    @connection = new RTCPeerConnection peerConnectionConfig, peerDataConnectionConfig
    @connection.onnegotiationneeded = @onRTCNegotiationNeeded
    @connection.onicecandidate = @onRTCIceCandidate
    @connection.ondatachannel = @onRTCDataChannel

  updateSenderCandidate: (data) =>
    return if data.target isnt @getOwnClientId()
    @connection.addIceCandidate new RTCIceCandidate(data.body)

  updateSenderOffer: (data) =>
    return if data.target isnt @getOwnClientId()
    @connection.setRemoteDescription new RTCSessionDescription(data.body)
    @connection.createAnswer (answer) =>
      @connection.setLocalDescription answer, =>
        @sendWebSocketMessage "update_receiver_answer", answer

  updateFileinfo: (data) =>
    @file = data.body

  attachDataChannel: (@channel) =>
    @channel.onopen = @onRTCChannelOpen
    @channel.onmessage = @onRTCChannelMessage

  getOwnClientId: ->
    @websocket._conn.connection_id

  sendWebSocketMessage: (event_name, body) ->
    message = sender: @getOwnClientId(), target: @target_client_id, body: body
    @websocket.trigger event_name, message

  onRTCIceCandidate: (event) =>
    console.log "onRTCIceCandidate"
    if event.candidate
      @sendWebSocketMessage "update_receiver_candidate", event.candidate

  onRTCDataChannel: (event) =>
    console.log "onRTCDataChannel"
    @attachDataChannel event.channel

  onRTCNegotiationNeeded: (event) =>
    console.log "onRTCNegotiationNeeded"

  onRTCChannelOpen: =>
    console.log "onRTCChannelOpen"

  onRTCChannelMessage: (event) =>
    console.log "onRTCChannelMessage"
    @receiveFile event

  sendRTCMessage: (event) ->
    @channel.send event

  ## FILES
  receiveFile: (event) =>
    @dataBuffer ?= ""
    @dataBuffers ?= []

    percent = @dataBuffer.length/(@file.size * 1.33)
    if not $('#loader_outer').is(':visible')
      $("#loader_outer").fadeIn(500)
    $("#loader").css("width", percent*100 + "%")

#    console.log event.data, typeof  event.data
    if event.data == "\n"
      console.log "おわり"
#      @dataBuffer = @dataBuffers.join ""
#      console.log @dataBuffer
      window.dataBuffer = @dataBuffer
      Base64toBlob @dataBuffer
      $("#loader_outer").fadeOut(1000)
#      console.log @dataBuffer

      if @isDownloadMode
#        @downloadFile()
        DonwloadBlob Base64toBlob(@dataBuffer), @file
      else
        window.open @dataBuffer

      console.log @file
#      @dataBuffer = ""
#      @dataBuffers = []
#    downloadURI(dataBuffer)
#    dataBuffer = ""
      return
    @dataBuffer += event.data
    @sendRTCMessage "-"

  downloadFile: ->
    @dataBuffer = @dataBuffer.replace /^data:.*?;/, "data:application/octet-stream;"
    location.href = @dataBuffer
#    link = document.createElement("a")
#    link.download = @file.name
#    link.href = @dataBuffer
#    link.click()

class FTPObserver
  constructor: (@websocket) ->
    websocket.bind "ftp_hello", @onFTPHello
    websocket.bind "ftp_ok", @onFTPOk

  onFTPHello: (data) =>
    return if data.target isnt @getOwnClientId()
    console.log "onFTPHello"
    @target_client_id = data.sender
    @receiver = new FileReceiver @target_client_id, @websocket
    @sendWebSocketMessage "ftp_ok", ""

  onFTPOk: (data) =>
    return if data.target isnt @getOwnClientId()
    console.log "onFTPOk"
    @sender = new FileSender @target_client_id, @waitingFile, @websocket

  getOwnClientId: ->
    console.log "getOwnClientId"
    @websocket._conn.connection_id

  sendWebSocketMessage: (event_name, body) ->
    console.log "sendWebSocketMessage"
    message = sender: @getOwnClientId(), target: @target_client_id, body: body
    @websocket.trigger event_name, message

  sendFile: (target_id, file) ->
    console.log "sendFile"
    @target_client_id = target_id
    @waitingFile = file
    @sendWebSocketMessage "ftp_hello", ""

window.FileSender = FileSender
window.FileReceiver = FileReceiver
window.FTPObserver = FTPObserver

$ ->
  websocket = new WebSocketRails "ws://"+location.host+"/websocket"
  websocket.bind "update_users", (users) ->
    $("#user_list").empty()
    for client_id, user of users
      if client_id is websocket._conn.connection_id
        $("#user_self > img").attr("src", "http://www.gravatar.com/avatar/"+user.client_id+"?d=retro")
        $("#user_self > p").text(user.name)
        continue
      console.log user
      user_icon = $("<li>").addClass("user_icon").append(
        $("<img>").attr("src", "http://www.gravatar.com/avatar/"+user.client_id+"?d=retro")
      ).append(
        $("<p>").text(user.name)
      ).data("user", user)
      user_icon.bind "dradenter", cancelEvent
      user_icon.bind "dragover", overEvent
      user_icon.bind "dragleave", leaveEvent
      user_icon.bind "drop", dropEvent
      $("#user_list").append user_icon
  window.ws = websocket
  observer = new FTPObserver websocket

  downloadURI = (uri) ->
    link = document.createElement("a")
    link.download = "download"
    link.href = uri
    link.click()

  dataBuffer = ""
  element = $ ".user_icon"

  pollingFile = null

  if !window.FileReader
    alert "File API not supported."
    return false

  cancelEvent = (event) ->
    event.preventDefault();
    event.stopPropagation();
    return false

  overEvent = (event) ->
    $(@).addClass "hover"
    cancelEvent event

  leaveEvent = (event) ->
    $(@).removeClass "hover"
    cancelEvent event

  dropEvent = (event) ->
    $(@).removeClass "hover"
    file = event.originalEvent.dataTransfer.files[0];
    observer.sendFile $(@).data("user").client_id, file
    console.log file
    cancelEvent event
    return false

  element.bind "dradenter", cancelEvent
  element.bind "dragover", overEvent
  element.bind "dragleave", leaveEvent
  element.bind "drop", dropEvent

  element2 = $ "#selectable_file"
  selectEvent = (event) ->
    file = event.target.files[0]
    openFile file
  element2.bind "change", selectEvent