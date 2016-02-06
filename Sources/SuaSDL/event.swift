
import CSDL


public struct SEvent {

  public let sdlEvent: SDL_Event
  var _preventDefault: Bool
  var _stopPropagation: Bool
  var _stopImmediatePropagation: Bool

  public func textAsString() -> String? {
    var t = sdlEvent.text
    return withUnsafePointer(&t.text) { ptr -> String? in
      return String.fromCString(UnsafePointer<CChar>(ptr))
    }
  }

  public var key: Int32 {
    return sdlEvent.key.keysym.sym
  }

  public var isShiftKey: Bool {
    let c = sdlEvent.key.keysym.mod
    return (c & S.KMOD_LSHIFT > 0) || (c & S.KMOD_RSHIFT > 0)
  }

  public var isCtrlKey: Bool {
    let c = sdlEvent.key.keysym.mod
    return (c & S.KMOD_LCTRL > 0) || (c & S.KMOD_RCTRL > 0)
  }

  public var isAltKey: Bool {
    let c = sdlEvent.key.keysym.mod
    return (c & S.KMOD_LALT > 0) || (c & S.KMOD_RALT > 0)
  }

  public mutating func preventDefault() {
    _preventDefault = true
  }

  public mutating func stopPropagation() {
    _stopPropagation = true
  }

  public mutating func stopImmediatePropagation() {
    _stopPropagation = true
    _stopImmediatePropagation = true
  }

  public static func new(ev: SDL_Event) -> SEvent {
    return SEvent(sdlEvent: ev, _preventDefault: false,
        _stopPropagation: false, _stopImmediatePropagation: false)
  }

}


public typealias SEventHandler = (inout ev: SEvent) -> Void


struct SEventHandlerId {
  var handler: SEventHandler
  var id: Int
}


public enum SEventType {
  case TextInput
  case Quit
  case KeyUp
  case KeyDown
  case MouseMotion
  case MouseButtonDown
  case MouseButtonUp
  case MouseWheel
  case MouseClick         // Custom event.
  case Focus              // Custom event.
  case Blur               // Custom event.
}


public class CustomSEvent {

  var items = [SEventHandlerId]()

  public func listen(fn: SEventHandler) -> Int {
    let id = CustomSEvent.genId()
    items.append(SEventHandlerId(handler: fn, id: id))
    return id
  }

  public func doRemove(id: Int) {
    let mi = items.indexOf() { af in
      return af.id == id
    }
    if let i = mi {
      items.removeAtIndex(i)
    }
  }

  public func signal(inout ev: SEvent) {
    for af in items {
      if ev._stopImmediatePropagation {
        break
      }
      af.handler(ev: &ev)
    }
  }

  public var isEmpty: Bool {
    return items.count == 0
  }

  public func clear() {
    items.removeAll()
  }

  static var _genId = 0

  static func genId() -> Int {
    _genId += 1
    return _genId
  }

}


public class EventStore {

  public var customEvents = [SEventType: CustomSEvent]()

  public subscript(eventType: SEventType) -> CustomSEvent? {
    get { return customEvents[eventType] }
    set { customEvents[eventType] = newValue }
  }

  // Returns the id that can be used for removing the handler.
  public func on(eventType: SEventType, fn: SEventHandler) -> Int {
    var a = customEvents[eventType]
    if a == nil {
      a = CustomSEvent()
    }
    let id = a!.listen(fn)
    customEvents[eventType] = a!
    return id
  }

  public func signal(eventType: SEventType, ev: SDL_Event) -> SEvent? {
    if let a = customEvents[eventType] {
      var se = SEvent.new(ev)
      a.signal(&se)
      return se
    }
    return nil
  }

  public func signal(eventType: SEventType, inout ev: SEvent) {
    if let a = customEvents[eventType] {
      a.signal(&ev)
    }
  }

  public func hasListenerFor(eventType: SEventType) -> Bool {
    if let a = customEvents[eventType] {
      return !a.isEmpty
    }
    return false
  }

}
