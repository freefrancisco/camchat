
class @Tokbox      
  @initSession =  (mode='webrtc') =>
    @_private.initialize(mode)
    @streams = []
    @streamIds = []
    # TB.setLogLevel TB.DEBUG
    TB.addEventListener 'exception', @handlers.exception
    @session = TB.initSession @sessionId
    handlerFunctions = ['sessionConnected', 'sessionDisconnected', 'streamCreated', 'streamDestroyed', 'connectionCreated', 'connectionDestroyed']
    @session.addEventListener x, @handlers[x] for x in handlerFunctions
    @session.connect @apiKey, @token
    
  @resetHtml = =>
    $('div#streams').html '<div id="myPublisherDiv"></div>'

  @handlers =
    exception: (event) =>
      p "EXCEPTION!!"
      p "exception", event
    connectionCreated: (event) =>
      p "connectionCreated", event
      
    connectionDestroyed: (event) =>
      p "connectionDestroyed", event
      
    sessionConnected: (event) =>
      p "sessionConnected", event
      @publisher = TB.initPublisher @apiKey, "myPublisherDiv"
      @session.publish @publisher
      @handlers.subscribeToStreams event.streams
      
    sessionDisconnected: (event) =>
      p "sessionDisconnected", event

    streamCreated: (event) =>
      p "streamCreated", event
      @handlers.subscribeToStreams event.streams
      
    streamDestroyed: (event) =>
      p "streamDestroyed", event
      
    subscribeToStreams: (streams) =>
      p "subscribeToStreams", streams
      p "streams connection ids", (s.connection.connectionId for s in streams)
      p "streams ids", (s.streamId for s in streams)
      p "my streams", @streams
      p "my stream ids", @streamIds
      for s in streams
        return if s.connection.connectionId is @session.connection.connectionId
        return if !!~@streams.indexOf s.connection.connectionId
        p "did not return for stream id #{s.streamId}, conn id #{s.connection.connectionId}"
        @handlers.subscribeToStream s
        
    subscribeToStream: (stream) => 
      p "subscribeToStream", stream  
      p "subscribe to stream #{stream.streamId}, #{stream.connection.connectionId}"
      @streams.push stream.connection.connectionId
      @streamIds.push stream.streamId
      div = document.createElement "div"
      div.setAttribute "id", "stream#{stream.streamId}"
      $('#streams').append div
      @session.subscribe stream, div.id
      
    

  @_private =
    initialize: (mode) =>
      @_private.reset()
      @apiKey = "1127"
      if mode is 'flash' 
        TBFlash()
        @sessionId = "1_MX4xMTI3fn5XZWQgSnVuIDI2IDAwOjEzOjE3IFBEVCAyMDEzfjAuNzE2MzQ4MDV-"
        @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz00ZDg1MjY1YzBiNTdkMzM0MzQ1MGNiODBhN2U0OTJhOTdhZGM4ODgzOnNlc3Npb25faWQ9MV9NWDR4TVRJM2ZuNVhaV1FnU25WdUlESTJJREF3T2pFek9qRTNJRkJFVkNBeU1ERXpmakF1TnpFMk16UTRNRFYtJmNyZWF0ZV90aW1lPTEzNzIyMzA3OTcmbm9uY2U9MTAwMzkwJnJvbGU9cHVibGlzaGVy"
      else if mode is 'webrtc'
        TBWebrtc()
        @sessionId = "1_MX4xMTI3fn5XZWQgSnVuIDI2IDAwOjI2OjI4IFBEVCAyMDEzfjAuOTMwNDE1OX4"
        @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz1lODg1YmI3YzVmNmU1N2QzMjNmYWM4ZmZkNjJmZjQ4NGY3OWJjYzFjOnNlc3Npb25faWQ9MV9NWDR4TVRJM2ZuNVhaV1FnU25WdUlESTJJREF3T2pJMk9qSTRJRkJFVkNBeU1ERXpmakF1T1RNd05ERTFPWDQmY3JlYXRlX3RpbWU9MTM3MjIzMTU4OCZub25jZT04Njc2MDgmcm9sZT1wdWJsaXNoZXI="
        @sessionId = "1_MX4xMTI3fn5XZWQgSnVuIDI2IDE5OjUyOjI3IFBEVCAyMDEzfjAuOTM3Njk1N34"
        @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz1lNmJjYTY5NWMxMzk1OTZlODgwMzBjZjZhMzBkMWY0NDA3MzVhZGRkOnNlc3Npb25faWQ9MV9NWDR4TVRJM2ZuNVhaV1FnU25WdUlESTJJREU1T2pVeU9qSTNJRkJFVkNBeU1ERXpmakF1T1RNM05qazFOMzQmY3JlYXRlX3RpbWU9MTM3MjMwMTU0NyZub25jZT0zMjQzODgmcm9sZT1wdWJsaXNoZXI="
      else
        alert 'You need to specify either webrtc or flash as mode in runVideo'
      
      
    reset: =>
      @resetHtml()
      delete TB
    
# Meteor.startup ->
  # mode = if $.browser.chrome then 'webrtc' else 'flash'
  # Tokbox.initSession mode
