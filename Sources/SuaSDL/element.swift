
import _Sua


public protocol Element: class {
  var type: SType { get }
  var maxWidth: Int { get set }
  var maxHeight: Int { get set }
  var width: Int { get set }
  var height: Int { get set }
  var borderTop: Bool { get set }
  var borderRight: Bool { get set }
  var borderBottom: Bool { get set }
  var borderLeft: Bool { get set }
  var borderType: BorderType { get set }
  var expandWidth: Bool { get set }
  var expandHeight: Bool { get set }
  var expandParentWidth: Bool { get set }
  var expandParentHeight: Bool { get set }
  var backgroundStrings: [String] { get set }
  var borderBackgroundColor: Color? { get set }
  var borderColor: Color? { get set }
  var _borderStyle: Int32 { get set }
  var lastx: Int { get set }
  var lasty: Int { get set }
  var lastSize: TellSize { get set }
  var eventStore: EventStore? { get set }


  func tellSize() -> TellSize

  func draw(x: Int, y: Int, size: TellSize)

  func drawBorder(x: Int, y: Int, size: TellSize) -> Point

  func drawBackground(x: Int, y: Int, width: Int, height: Int,
      strings: [String])

  func on(eventType: SEventType, fn: SEventHandler) -> Int

  func signal(eventType: SEventType, inout ev: SEvent)

  func hasListenerFor(eventType: SEventType) -> Bool

}


extension Element {

  public func drawBorder(x: Int, y: Int, size: TellSize) -> Point {
    let w = size.width
    let h = size.height
    if w <= 0 || h <= 0 {
      return Point.far
    }
    var ny = y
    var nx = x
    var borderHeight = h
    if size.borderTop > 0 {
      var si = 0
      var ei = w
      if size.borderRight > 0 {
        S.textGrid.move(nx + w - 1, y: ny)
        S.textGrid.add("╮")
        ei -= 1
      }
      S.textGrid.move(nx, y: ny)
      if size.borderLeft > 0 {
        S.textGrid.add("╭")
        si += 1
      }
      if si < ei {
        for _ in si..<ei {
          S.textGrid.add("─")
        }
      }
      ny += 1
      borderHeight -= 1
    }
    if size.borderBottom > 0 {
      borderHeight -= 1
      var si = 0
      var ei = w
      if size.borderRight > 0 {
        S.textGrid.move(nx + w - 1, y: ny + borderHeight)
        S.textGrid.add("╯")
        ei -= 1
      }
      S.textGrid.move(nx, y: ny + borderHeight)
      if size.borderLeft > 0 {
        S.textGrid.add("╰")
        si += 1
      }
      if si < ei {
        for _ in si..<ei {
          S.textGrid.add("─")
        }
      }
    }
    if size.borderRight > 0 {
      let ei = ny + borderHeight
      let bx = nx + w - 1
      if ny < ei {
        for i in ny..<ei {
          S.textGrid.move(bx, y: i)
          S.textGrid.add("│")
        }
      }
    }
    if size.borderLeft > 0 {
      let ei = ny + borderHeight
      if ny < ei {
        for i in ny..<ei {
          S.textGrid.move(nx, y: i)
          S.textGrid.add("│")
        }
      }
      nx += 1
    }
    return Point(x: nx, y: ny)
  }

  public func drawBackground(x: Int, y: Int, width: Int, height: Int,
      strings: [String]) {
    assert(width >= 0 && height >= 0)
    let blen = strings.count
    if blen == 0 || strings[0].isEmpty {
      return
    }
    let ey = y + height
    let ex = x + width
    if blen == 1 {
      let a = Array(strings[0].characters)
      let len = a.count
      let s = strings[0]
      if len == 1 {
        for i in y..<ey {
          S.textGrid.move(x, y: i)
          for _ in x..<ex {
            S.textGrid.add(s)
          }
        }
      } else {
        let limit = ex - len + 1
        for i in y..<ey {
          S.textGrid.move(x, y: i)
          var j = x
          while j < limit {
            S.textGrid.add(s)
            j += len
          }
          if j < ex {
            S.textGrid.add(s.characters.substring(0, endIndex: ex - j))
          }
        }
      }
    } else {
      var si = 0
      let blen = strings.count
      for i in y..<ey {
        let s = strings[si]
        let slen = s.characters.count
        let limit = ex - slen + 1
        S.textGrid.move(x, y: i)
        var j = x
        while j < limit {
          S.textGrid.add(s)
          j += slen
        }
        if j < ex {
          S.textGrid.add(s.characters.substring(0, endIndex: ex - j))
        }
        si += 1
        if si >= blen {
          si = 0
        }
      }
    }
  }

  // Handles only .Right and .Center types.
  public func commonAlign(type: TextAlign, availableWidth: Int) -> Int {
    var r = availableWidth
    if type == .Center {
      let share = availableWidth / 2
      r = share
      if (share * 2) < availableWidth {
        r += 1 // Favor extra space on the first half to better match the
                  // spacing done with expandWidth.
      }
    }
    return r
  }

  public func matchPoint(x: Int, y: Int) -> Bool {
    return x >= lastx &&  x <= lastx + lastSize.width - 1 && y >= lasty &&
        y <= lasty + lastSize.height - 1 &&
        lastSize.contentWidth > 0 && lastSize.contentHeight > 0
  }

  public var borderStyle: String {
    get { return "%#=" }
    set {
      borderColor = nil
      borderBackgroundColor = nil
      _borderStyle = 0
      do {
        let a = newValue.bytes
        let (hc, _) = try Hexastyle.parseHexastyle(a, startIndex: 1,
            maxBytes: a.count)
        if let ahc = hc {
          _borderStyle = ahc.toSStyle()
          if let ac = ahc.color {
            borderColor = Color(r: ac.r, g: ac.g, b: ac.b,
                a: ac.a != nil ? ac.a! : 255)
          }
          if let ac = ahc.backgroundColor {
            borderBackgroundColor = Color(r: ac.r, g: ac.g, b: ac.b,
                a: ac.a != nil ? ac.a! : 255)
          }
          return
        }
      } catch {
        // Ignore.
      }
      // Show border in red to indicate error.
      borderColor = Color.red
    }
  }

  public func on(eventType: SEventType, fn: SEventHandler) -> Int {
    if eventStore == nil {
      eventStore = EventStore()
    }
    return eventStore!.on(eventType, fn: fn)
  }

  public func signal(eventType: SEventType, inout ev: SEvent) {
    if let es = eventStore {
      es.signal(eventType, ev: &ev)
    }
  }

  public func hasListenerFor(eventType: SEventType) -> Bool {
    if let es = eventStore {
      return es.hasListenerFor(eventType)
    }
    return false
  }

}


public protocol FocusElement: class {

  func _onKeyDown(ev: SEvent)

  func _onKeyUp(ev: SEvent)

  func _onTextInput(ev: SEvent)

  func _onFocus(ev: SEvent)

  func _onBlur(ev: SEvent)

  func signal(eventType: SEventType, inout ev: SEvent)

  func focus()

}


extension FocusElement {

  public func focus() {
    S.focus(self)
  }

}
