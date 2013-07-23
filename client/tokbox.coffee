
class @Tokbox
  constructor: (@mode, @canPublish, @fun) ->
    @funFirstTime = true
    
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
    if @publisherCount() < 1 and @canPublish #only allow one publisher
      @publisher = @TB.initPublisher @apiKey, "#{@mode}Publisher"
      @session.publish @publisher
    else
      p "Can only publish one stream at a time (#{@mode})"
    
    
  resetHtml: ->
    $('div#video').html '''
    <div id="myPublisherDiv"></div>
  	<div id="streams"></div>
    '''
    
  publisherCount: ->
    return 0 unless @session?.publishers
    (k for k of @session.publishers).length

  subscribeToStreams: (streams) ->
    p "subscribeToStreams (#{@mode})", streams
    p "streams connection ids", (s.connection.connectionId for s in streams)
    p "streams ids", (s.streamId for s in streams)
    p "my streams", @streams
    p "my stream ids", @streamIds
    for s in streams
      return if s.connection.connectionId is @session.connection.connectionId
      # return if !!~@streams.indexOf s.connection.connectionId
      p "did not return for stream id #{s.streamId}, conn id #{s.connection.connectionId}"
      @subscribeToStream s
      
  subscribeToStream: (stream) -> 
    p "subscribeToStream (#{@mode})", stream  
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
    p "exception (#{@mode})", event
  sessionConnectedHandler: (event) =>
    p "sessionConnected (#{@mode})", event
    @subscribeToStreams event.streams
    @publish()
    
  connectionCreatedHandler: (event) =>
    p "connectionCreated (#{@mode})", event
    @subscribeToStreams event.streams if event.streams
    
  streamCreatedHandler: (event) =>
    p "streamCreated (#{@mode})", event
    @subscribeToStreams event.streams
    if @fun? and @funFirstTime
      @fun() 
      @funFirstTime = false
    
    
  streamDestroyedHandler: (event) =>
    p "streamDestroyed (#{@mode})", event
    
  connectionDestroyedHandler: (event) =>
    p "connectionDestroyed (#{@mode})", event
    
  sessionDisconnectedHandler: (event) =>
    p "sessionDisconnected (#{@mode})", event

    
  _initialize: (mode) -> #don't call this by itself, it will kill TB before it's ready for other technology
    delete TB if TB?
    @apiKey = "1127"
    TBWebrtc()
    @sessionId = "2_MX4xMTI3fn5Nb24gSnVsIDIyIDIxOjIzOjI1IFBEVCAyMDEzfjAuMDAzMTg4NDkwOX4"
    @token = "T1==cGFydG5lcl9pZD0xMTI3JnNpZz00YTRjMzZhNDY1Njc3MGM0MjI5NTY2ODZiOTRhMDkyOWUxMTVhZGEwOnNlc3Npb25faWQ9Ml9NWDR4TVRJM2ZuNU5iMjRnU25Wc0lESXlJREl4T2pJek9qSTFJRkJFVkNBeU1ERXpmakF1TURBek1UZzRORGt3T1g0JmNyZWF0ZV90aW1lPTEzNzQ1NTM0MDYmbm9uY2U9ODA5MTU5JnJvbGU9cHVibGlzaGVy"
    @TB = TB
    

Meteor.startup ->
  canPublish = true # if $.browser.chrome then true else false
  # @f = new Tokbox 'flash', canPublish
  @w = new Tokbox 'webrtc', canPublish#, (-> w.go())
  w.go()
  # mode = if $.browser.chrome then 'webrtc' else 'flash'
  # Tokbox.initSession mode
