
class @Tokbox
  constructor: (@mode) ->
    
  go: ->
    @initSession()
    @connect()
    
    
  initSession: ->
    @_initialize(@mode)
    @streams = []
    @streamIds = []
    # @TB.setLogLevel TB.DEBUG
    @TB.addEventListener 'exception', @exceptionHandler
    @session = @TB.initSession @sessionId
    @session.addEventListener x, @["#{x}Handler"] for x in ['sessionConnected', 'connectionCreated', 
    'streamCreated', 'sessionDisconnected', 'connectionDestroyed', 'streamDestroyed']
    @session
  
  connect: ->
    @session.connect @apiKey, @token
    
  publish: ->
    if @publisherCount() < 1 #only allow one publisher
      @publisher = @TB.initPublisher @apiKey, "#{@mode}Publisher"
      @session.publish @publisher
    else
      p "Can only publish one stream at a time"
    
    
  resetHtml: ->
    $('div#video').html '''
    <div id="myPublisherDiv"></div>
  	<div id="streams"></div>
    '''
    
  publisherCount: ->
    return 0 unless @session?.publishers
    (k for k of @session.publishers).length

  subscribeToStreams: (streams) ->
    p "subscribeToStreams", streams
    p "streams connection ids", (s.connection.connectionId for s in streams)
    p "streams ids", (s.streamId for s in streams)
    p "my streams", @streams
    p "my stream ids", @streamIds
    for s in streams
      return if s.connection.connectionId is @session.connection.connectionId
      return if !!~@streams.indexOf s.connection.connectionId
      p "did not return for stream id #{s.streamId}, conn id #{s.connection.connectionId}"
      @subscribeToStream s
      
  subscribeToStream: (stream) -> 
    p "subscribeToStream", stream  
    p "subscribe to stream #{stream.streamId}, #{stream.connection.connectionId}"
    @streams.push stream.connection.connectionId
    @streamIds.push stream.streamId
    div = document.createElement "div"
    div.setAttribute "id", "stream#{stream.streamId}"
    $('#streams').append div
    @session.subscribe stream, div.id
    
  #handlers
  exceptionHandler: (event) =>
    p "EXCEPTION!!"
    p "exception", event
  sessionConnectedHandler: (event) =>
    p "sessionConnected", event
    @subscribeToStreams event.streams
    # delete TB
    
  connectionCreatedHandler: (event) =>
    p "connectionCreated", event
    
  streamCreatedHandler: (event) =>
    p "streamCreated", event
    @subscribeToStreams event.streams
    
  streamDestroyedHandler: (event) =>
    p "streamDestroyed", event
    
  connectionDestroyedHandler: (event) =>
    p "connectionDestroyed", event
    
  sessionDisconnectedHandler: (event) =>
    p "sessionDisconnected", event

    
  _initialize: (mode) -> #don't call this by itself, it will kill TB before it's ready for other technology
    delete TB if TB?
    @apiKey = "1127"
    if mode is 'flash' 
      TBFlash()
      @sessionId = "1_MX4xMTI3fn5Nb24gSnVuIDE3IDE0OjI3OjA5IFBEVCAyMDEzfjAuNDkzNzk5MDN-"
      @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz0wYzc3Mzc5MWEzNDA5MzdmZTZlZjVkZDMxNWU1NTcyN2VkYjJlOWU0OnNlc3Npb25faWQ9MV9NWDR4TVRJM2ZuNU5iMjRnU25WdUlERTNJREUwT2pJM09qQTVJRkJFVkNBeU1ERXpmakF1TkRrek56azVNRE4tJmNyZWF0ZV90aW1lPTEzNzIzMzEwMTcmbm9uY2U9MjcxMDYzJnJvbGU9cHVibGlzaGVy"
    else if mode is 'webrtc'
      TBWebrtc()
      @sessionId = "1_MX4xMTI3fn5XZWQgSnVuIDI2IDE5OjUyOjI3IFBEVCAyMDEzfjAuOTM3Njk1N34"
      @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz1lNmJjYTY5NWMxMzk1OTZlODgwMzBjZjZhMzBkMWY0NDA3MzVhZGRkOnNlc3Npb25faWQ9MV9NWDR4TVRJM2ZuNVhaV1FnU25WdUlESTJJREU1T2pVeU9qSTNJRkJFVkNBeU1ERXpmakF1T1RNM05qazFOMzQmY3JlYXRlX3RpbWU9MTM3MjMwMTU0NyZub25jZT0zMjQzODgmcm9sZT1wdWJsaXNoZXI="
    else
      alert 'You need to specify either webrtc or flash as mode in runVideo'
    @TB = TB
    
    
# Meteor.startup ->
  # mode = if $.browser.chrome then 'webrtc' else 'flash'
  # Tokbox.initSession mode
