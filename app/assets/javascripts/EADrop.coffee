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

class FileTransfer
  constructor: (@file, isSender) ->
    @source = if isSender then "sender" else "receiver"
    @channel = null

    @websocket = new WebSocketRails "ws://"+location.host+"/websocket"
    @websocket.bind "water", @webSocketListener

    @connection = new RTCPeerConnection peerConnectionConfig, peerDataConnectionConfig
    @connection.onnegotiationneeded = ->
      console.log "ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!"
    @connection.onicecandidate = (event) =>
      if event.candidate
        @sendWebSocketMessage "candidate", event.candidate
    @connection.ondatachannel = (event) =>
      console.log event
      @attachDataChannel event.channel

#    @ = "hoge"
    @initializeSender() if isSender

  initializeSender: ->
    @attachDataChannel @connection.createDataChannel "channel", reliable: true
#    @connection.createOffer @createdOffer
    @connection.createOffer (description) =>
      console.log "OnCreateOffer 1"
      @connection.setLocalDescription description, =>
        console.log "OnSetLocalDescription 2"
        @sendWebSocketMessage "description", description
        $("#sender_local").val JSON.stringify(description)

#  createdOffer: (description) ->
#    console.log "OnCreateOffer 1"
#    @connection.setLocalDescription desctipion
#    @sendWebSocketMessage "description", description

#  createdAnswer: (answer) ->

  getTarget: ->
    if @source == "receiver" then "sender" else "receiver"

  attachDataChannel: (@channel) ->
    @channel.onopen = ->
      console.log "onopen"
    @channel.onmessage = (message) =>
#      console.log "ぴーかー"
      if @rtcMessageListener?
        @rtcMessageListener(message)
#      console.log "onmessage"
#      console.log message
    console.log "データちゃんねる来ちゃった。。。a"

  sendWebSocketMessage: (type, body) ->
    message = target: @getTarget(), type: type, body: body
    @websocket.trigger "fire", message

  webSocketListener: (data) =>
    console.log data.target, @source
    if data.target != @source
      return
    console.log data

    # candidateが送られてきた場合
    if data.type == "candidate"
      @connection.addIceCandidate new RTCIceCandidate(data.body)

    # descriptionが送られてきた場合
    if data.type == "description"
      @connection.setRemoteDescription new RTCSessionDescription(data.body)
      if data.target == "receiver"
        @connection.createAnswer (answer) =>
          @connection.setLocalDescription answer, =>
            @sendWebSocketMessage "description", answer

  setRTCMessageListener: (listener) ->
    @rtcMessageListener = listener

  sendRTCMessage: (message) ->
    @channel.send message

window.FileTransfer = FileTransfer

$ ->
#  ws = new WebSocketRails "ws://localhost:3000/websocket"
#  connection = new RTCPeerConnection(peerConnectionConfig, peerDataConnectionConfig)
#  channel = null
#  candidate = []
#
#  createChannel = (c) ->
#    channel = c
#    channel.onopen = ->
#      console.log "onopen"
#    channel.onmessage = ->
#      console.log "onmessage"
#    connection.onicecandidate = (event) ->
#      console.log "おっすおら悟空"
#      if event.candidate
#        candidate.push event.candidate
#        $("#candidate_text").val(JSON.stringify(candidate))
##        connection.addIceCandidate event.candidate
#
##  connection.onnegotiationneeded = ->
##    console.log "ｷﾀ━━━━(ﾟ∀ﾟ)━━━━!!"
#
#  connection.onsignalingstatechange = (event) ->
#    console.log event
#  connection.ondatachannel = (event) ->
#    createChannel(event.channel)
#    console.log event.channel
#    console.log "データちゃんねる来ちゃった。。。"
#
#  $("#candidate_button").click ->
#    a = JSON.parse $("#candidate_text").val()
#    connection.addIceCandidate new RTCIceCandidate c for c in candidate
#
#  $("#channel_button").click ->
#    channel.send "hello"
#
#  $("#sender_button1").click ->
#    createChannel(connection.createDataChannel "channel", reliable: true)
#    connection.createOffer (description) ->
#      console.log "OnCreateOffer"
#      connection.setLocalDescription description, ->
#        console.log "OnSetLocalDescription"
#        $("#sender_local").val JSON.stringify(description)
#  $("#sender_button2").click ->
#    remoteDescription = new RTCSessionDescription JSON.parse($("#sender_remote").val())
#    connection.setRemoteDescription remoteDescription
##    openChannel()
#
#  $("#receiver_button").click ->
#    remoteDescription = new RTCSessionDescription JSON.parse($("#receiver_remote").val())
#    connection.setRemoteDescription remoteDescription
#    connection.createAnswer (answer) ->
#      connection.setLocalDescription answer, ->
#        $("#receiver_local").val JSON.stringify(answer)
##          openChannel()
#  openChannel = ->

  downloadURI = (uri) ->
    link = document.createElement("a")
    link.download = "download"
    link.href = uri
    link.click()

  dataBuffer = ""
  session = null
  $("#sender_button").click ->
    session = new FileTransfer null, true
  $("#receiver_button").click ->
    session = new FileTransfer null, false
    session.setRTCMessageListener (event) ->
#      console.log "ぴーかー"
      if event.data == "\n"
        console.log "おわり"
        console.log dataBuffer
#        window.open dataBuffer
        downloadURI(dataBuffer)
        dataBuffer = ""
      else
        dataBuffer += event.data

  sendFile = (file) ->
    reader = new FileReader
    reader.onload = (event) ->
      delay = 10;
      charSlice = 10000;
      terminator = "\n";
      data = event.target.result;
      dataSent = 0;
      intervalID = 0;

      intervalID = setInterval ->
        slideEndIndex = dataSent + charSlice
        if slideEndIndex > data.length
          slideEndIndex = data.length
        session.sendRTCMessage data.slice(dataSent, slideEndIndex)
        dataSent = slideEndIndex
        if dataSent + 1 >= data.length
          console.log "送信完了"
          dataSent = 0
          dataBuffer = ""
          session.sendRTCMessage "\n"
          clearInterval intervalID
      , delay
    reader.readAsDataURL file

  openFile = (file) ->
    console.log file
    sendFile file

  element = $ "#droppable_file"

  if !window.FileReader
    alert "File API not supported."
    return false

  cancelEvent = (event) ->
    event.preventDefault();
    event.stopPropagation();
    return false

  overEvent = (event) ->
    element.addClass "hover"
    cancelEvent event

  leaveEvent = (event) ->
    element.removeClass "hover"
    cancelEvent event

  dropEvent = (event) ->
    element.removeClass "hover"
    file = event.originalEvent.dataTransfer.files[0];
    openFile file
#    console.log file
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
#    console.log event.target.files[0]
  element2.bind "change", selectEvent