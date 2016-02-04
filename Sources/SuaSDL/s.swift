
import Glibc
import CSua
import CSDL
import _Sua


public enum SError: ErrorType {
  case Init(message: String)
  case CreateWindow(message: String)
  case CreateRenderer(message: String)
  case FontInit(message: String)
  case FontLoad(message: String)
}


public typealias Color = SDL_Color


public struct SEvent {

  public let sdlEvent: SDL_Event
  var _preventDefault: Bool
  var _cancelPropagation: Bool

  public func textAsString() -> String? {
    var t = sdlEvent.text
    return withUnsafePointer(&t.text) { ptr -> String? in
      return String.fromCString(UnsafePointer<CChar>(ptr))
    }
  }

  public mutating func preventDefault() {
    _preventDefault = true
  }

  public mutating func cancelPropagation() {
    _cancelPropagation = true
  }

  public static func new(ev: SDL_Event) -> SEvent {
    return SEvent(sdlEvent: ev, _preventDefault: false,
        _cancelPropagation: false)
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


extension Color {

  public func toHexa() -> String {
    func check(s: String) -> Bool {
      let c = s.utf16.codeUnitAt(0)
      return c == 48 || c == s.utf16.codeUnitAt(1)
    }
    func subs(s: String) -> String {
      if let z = s.utf16.substring(1, endIndex: 2) {
        return z
      }
      return "0"
    }
    let rs = HexaUtils.hexaToString(r, pad: true)
    let gs = HexaUtils.hexaToString(g, pad: true)
    let bs = HexaUtils.hexaToString(b, pad: true)
    let _a = HexaUtils.hexaToString(a, pad: true)
    if check(rs) && check(gs) && check(bs) && check(_a) {
      return subs(rs) + subs(gs) + subs(bs) + subs(_a)
    }
    return rs + gs + bs + _a
  }

  public static let red = Color(r: 255, g: 0, b: 0, a: 255)

}


extension Hexastyle {

  public func toSStyle() -> Int32 {
    var n: Int32 = 0
    if isBold {
      n |= S.BOLD
    }
    if isUnderline {
      n |= S.UNDERLINE
    }
    if isStrikeOut {
      n |= S.STRIKETHROUGH
    }
    if isItalic {
      n |= S.ITALIC
    }
    return n
  }

}


// S stands for Simple, the first name of the SDL acronym.
// Rather than to have the SDL name repeated for our own custom classes, we
// have opted to just use the S prefix instead.
public class SImpl {

  public let WINDOW_SHOWN: UInt32    = 4
  public let QUIT: UInt32            = 256
  public let WINDOWEVENT: UInt32     = 512
  public let MOUSEMOTION: UInt32     = 1024
  public let MOUSEBUTTONDOWN: UInt32 = 1025
  public let MOUSEBUTTONUP: UInt32   = 1026
  public let MOUSEWHEEL: UInt32      = 1027
  public let TEXTINPUT: UInt32       = 771

  public let WINDOWEVENT_SHOWN: UInt8        = 1
  public let WINDOWEVENT_HIDDEN: UInt8       = 2
  public let WINDOWEVENT_EXPOSED: UInt8      = 3
  public let WINDOWEVENT_MOVED: UInt8        = 4
  public let WINDOWEVENT_RESIZED: UInt8      = 5
  public let WINDOWEVENT_SIZE_CHANGED: UInt8 = 6
  public let WINDOWEVENT_MINIMIZED: UInt8    = 7
  public let WINDOWEVENT_MAXIMIZED: UInt8    = 8
  public let WINDOWEVENT_RESTORED: UInt8     = 9
  public let WINDOWEVENT_ENTER: UInt8        = 10
  public let WINDOWEVENT_LEAVE: UInt8        = 11
  public let WINDOWEVENT_FOCUS_GAINED: UInt8 = 12
  public let WINDOWEVENT_FOCUS_LOST: UInt8   = 13
  public let WINDOWEVENT_CLOSE: UInt8        = 14

  public let WINDOW_RESIZABLE: UInt32 = 32

  public let KEY_DOWN: UInt16 = 768
  public let KEY_UP: UInt16   = 769

  public let RENDERER_ACCELERATED: UInt32 = 2

  public let BOLD = TTF_STYLE_BOLD
  public let UNDERLINE = TTF_STYLE_UNDERLINE
  public let ITALIC = TTF_STYLE_ITALIC
  public let STRIKETHROUGH = TTF_STYLE_STRIKETHROUGH

  public var customEvents = [SEventType: CustomSEvent]()
  public var _textGrid: TextGrid?

  public var textGrid: TextGrid {
    return _textGrid!
  }

  public var mainDiv = Div()

  public func start(fn: (inout div: Div) throws -> Void) throws {
    try doStart() {
      try fn(div: &self.mainDiv)
    }
  }

  public func doStart(fn: () throws -> Void) throws {

    if SDL_Init(UInt32(SDL_INIT_VIDEO)) < 0 {
      throw SError.Init(message: errorMessage)
    }

    defer { SDL_Quit() }

    let win = SDL_CreateWindow("Hello World!", 100, 100, 640, 480,
        WINDOW_SHOWN | WINDOW_RESIZABLE)

    if win == nil {
      throw SError.CreateWindow(message: errorMessage)
    }

    defer { SDL_DestroyWindow(win) }

    let rend = SDL_CreateRenderer(win, -1, RENDERER_ACCELERATED)
    // let rend = SDL_CreateRenderer(win, -1, 0)

    if rend == nil {
      throw SError.CreateRenderer(message: errorMessage)
    }

    if TTF_Init() == -1 {
      throw SError.FontInit(message: errorMessage)
    }

    defer { TTF_Quit() }

   let fontPath = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
  //  let fontPath = "/usr/share/fonts/truetype/freefont/FreeMono.ttf"

    let freeSans = TTF_OpenFont(fontPath, 12)

    if freeSans == nil {
      throw SError.FontLoad(message: errorMessage)
    }

    // TTF_SetFontHinting(freeSans, TTF_HINTING_NONE)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_MONO)
    TTF_SetFontHinting(freeSans, TTF_HINTING_LIGHT)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_NORMAL)

    //TTF_SetFontStyle(freeSans, TTF_STYLE_BOLD)

    SDL_SetRenderDrawColor(rend, 255, 255, 255, 255)

    _textGrid = TextGrid(renderer: rend, font: freeSans)

    let redColor = SDL_Color(r: 255, g: 0, b: 0, a: 255)
    let blackColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)
    let yellowColor = SDL_Color(r: 255, g: 255, b: 0, a: 255)
    let blueColor = SDL_Color(r: 0, g: 0, b: 255, a: 255)

    // func drawAgain() {
    //   textGrid.move(10, y: 1)
    //   textGrid.fontColor = blueColor
    //   textGrid.add("Hello SuaSDL!")
    //   textGrid.fontColor = blackColor
    //   textGrid.move(1, y: 10)
    //   textGrid.add("Leo")
    //   textGrid.add("nardo")
    //   textGrid.add("Voador")
    //   textGrid.move(1, y: 11)
    //   textGrid.add("surfaceMsg 0x0000000001971750")
    //   textGrid.move(1, y: 12)
    //   textGrid.add("Coração do João")
    //   textGrid.move(1, y: 13)
    //   textGrid.add("A")
    //   textGrid.add("b")
    //   textGrid.add("C")
    //   textGrid.add("d")
    //   textGrid.add("E")
    //   textGrid.add("f")
    //   textGrid.move(0, y: 14)
    //   textGrid.add("Gabriel")
    //   textGrid.move(1, y: 20)
    //   textGrid.fontColor = redColor
    //   textGrid.backgroundColor = yellowColor
    //   textGrid.add("╭───────────────────────────────────────────╮")
    //   textGrid.move(1, y: 21)
    //   textGrid.add("│                                           │")
    //   textGrid.move(1, y: 22)
    //   textGrid.add("╰───────────────────────────────────────────╯")
    //   textGrid.fontColor = blackColor
    //   textGrid.backgroundColor = nil
    // }

    var ev = SDL_Event()
    var done = false
    var invalidated = false
    var lastWidth: Int32 = -1
    var lastHeight: Int32 = -1

    func doDraw() {
      SDL_RenderClear(rend)
      mainDiv.mainDraw(0, y: 0, width: textGrid.width, height: textGrid.height)
      // drawAgain()
      SDL_RenderPresent(rend)
      invalidated = false
    }

    func checkSizeChange() {
      var w: Int32 = 0
      var h: Int32 = 0
      SDL_GetWindowSize(win, &w, &h)
      if w != lastWidth || h != lastHeight {
        lastWidth = w
        lastHeight = h
        textGrid.changeScreenSize(w, height: h)
        doDraw()
      }
    }

    checkSizeChange()

    mainDiv.expandWidth = true
    mainDiv.expandHeight = true

    try fn()
// SDL_StartTextInput()
// var textRect = SDL_Rect(x: 10, y: 10, w: 100, h: 30)
// SDL_SetTextInputRect(&textRect)
    while !done {
      while SDL_PollEvent(&ev) != 0 {
        invalidated = ev.type != MOUSEMOTION
        if ev.type == WINDOWEVENT {
          if ev.window.event == WINDOWEVENT_SIZE_CHANGED {
            checkSizeChange()
          }
        } else if ev.type == MOUSEBUTTONDOWN {
          p("mouse button down \(ev.button.x) \(ev.button.y) \(ev.button.clicks)")
        } else if ev.type == MOUSEBUTTONUP {
          p("mouse button up \(ev.button.x) \(ev.button.y) \(ev.button.clicks)")
          p("mainDiv \(mainDiv.lastx) \(mainDiv.lasty) \(mainDiv.lastSize.width) \(mainDiv.lastSize.height)")
          if let cp = textGrid.pointToCell(ev.button.x, y: ev.button.y) {
            p("cellPoint \(cp)")
            var a = [Element]()
            if mainDiv.pointToList(cp.x, y: cp.y, list: &a) {
              p("pointToList \(a)")
              if let e = a.last {
                if e.type == .Text {
                  p("Simon says: \((e as! Text).text)")
                  p("Hexastyle: \((e as! Text).style)")
                }
              }
            }
          }
        } else if ev.type == TEXTINPUT {
          // p("text input \(ev.textAsString())")
          signal(.TextInput, ev: ev)
        } else if ev.type == QUIT {
          if let se = signal(.Quit, ev: ev) {
            if !se._preventDefault {
              done = true
            }
          }
        }
      }
      if invalidated {
        doDraw()
      }
      // SDL_Delay(100)
      SDL_Delay(16)
    }
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

  var errorMessage: String {
    if let s = String.fromCString(SDL_GetError()) {
      return s
    } else {
      return "Meta error: Failed conversion to unicode."
    }
  }

}


public let S = SImpl()
