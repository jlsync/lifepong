isArray = Array.isArray or (obj) ->
  obj.constructor.toString().indexOf("Array") isnt -1

default_max_listeners = 100
class EventEmitter
  
  setMaxListeners: (n) ->
    @_events.maxListeners = n
  
  emit: (type) ->
    if type is 'error'
      if not isArray(@_events?.error?) or not @_events?.error.length
        if arguments[1] instanceof Error
          throw arguments[1]
        else throw new Error arguments[1].code
        return false
    
    handler = @_events?[type]
    return false unless @_events?[type]
    
    if typeof handler is 'function'
      switch arguments.length
        # fast cases
        when 1 then handler.call @
        when 2 then handler.call @, arguments[1]
        when 3 then handler.call @, arguments[2]
        else
          args = Array.prototype.slice.call arguments, 1
          handler.apply @, args
      return true
    else if isArrayhandler
      args = Array.prototype.slice.call arguments, 1
      listeners = handler.slice()
      for listener in listeners
        listener.apply this, args
    else
      return false


  addListener: (type, listener) ->
    if typeof listener isnt 'function'
      throw new Error 'addListener only takes instances of Function'

    @_events or= {}
    
    @emit 'newListener', type, listener

    if not @_events[type]
      @_events[type] = listener
    else if isArray(@_events[type])
      if not @_events[type].warned
        m = 0
        if @_events.maxListeners isnt undefined
          m = @_events.maxListeners
        else m = default_max_listeners
        if m and m > 0 and @_events[type].length > m
          @_events[type].warned = true
          console.error "warning: possible EventEmitter memory" + \
              "leak detected. #{@_events[type].length} listeners"
          console.trace()
      @_events[type].push listener
    else
      @_events[type] = [@_events[type], listener]

    return @


  on: EventEmitter.prototype.addListener

  once: (type, listener) ->
    g = =>
      @removeListener type, g
      listener.apply @, arguments
    @on type, g
    return @

  removeListener: (type, listener) ->
    if typeof listener isnt 'function'
      throw new Error 'removeListener only takes instances of Function'
    
    list = @_events?[type]
    return @ unless list
    
    if isArray list
      i = list.indexOf listener
      return @ if i < 0
      list.splice i, 1
      
      if list.length is 0
        delete @_events[type]
    else if @_events[type] is listener
      delete @_events[type]
    return @

  removeAllListeners: (type) ->
    if type and @_events?[type]
      @_events[type] = null
    return this

  listeners: (type) ->
    @_events or= {}
    @_events[type] or= []
    if not isArray @_events[type]
      @_events[type] = [@_events[type]]
    return @_events[type]

#(exports ? window).CustomEventEmitter = EventEmitter
(exports ? window).EventEmitter = EventEmitter
