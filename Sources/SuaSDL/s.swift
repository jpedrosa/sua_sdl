
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


// S stands for Simple, the first name of the SDL acronym.
// Rather than to have the SDL name repeated for our own custom classes, we
// have opted to just use the S prefix instead.
public class SImpl {

  public let WINDOW_SHOWN: UInt32 = 4
  public let QUIT: UInt32         = 256
  public let WINDOWEVENT: UInt32  = 512
  public let TEXTINPUT: UInt32    = 771

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

    let freeSans = TTF_OpenFont(fontPath, 12)

    if freeSans == nil {
      throw SError.FontLoad(message: errorMessage)
    }

    // TTF_SetFontHinting(freeSans, TTF_HINTING_NONE)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_MONO)
    TTF_SetFontHinting(freeSans, TTF_HINTING_LIGHT)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_NORMAL)

    //TTF_SetFontStyle(freeSans, TTF_STYLE_BOLD)

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
      SDL_SetRenderDrawColor(rend, 255, 255, 255, 255)
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

    while !done {
      while SDL_PollEvent(&ev) != 0 {
        invalidated = true
        if ev.type == WINDOWEVENT {
          if ev.window.event == WINDOWEVENT_SIZE_CHANGED {
            checkSizeChange()
          }
//          p("window event \(ev.window.event)")
        } else if ev.type == TEXTINPUT {
          p("text input \(ev.text)")
        } else if ev.type == QUIT {
          done = true
        }
      }
      if invalidated {
        doDraw()
      }
      // SDL_Delay(100)
      SDL_Delay(16)
    }
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


public class TextureCacheValue {
  var texture: COpaquePointer
  var width: Int32
  var count: Int
  var timestamp: Int

  init(texture: COpaquePointer, width: Int32, count: Int, timestamp: Int) {
    self.texture = texture
    self.width = width
    self.count = count
    self.timestamp = timestamp
  }

  deinit { SDL_DestroyTexture(texture) }

}


public class TextGrid {

  public var x = 0
  public var y = 0
  public var fontColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)
  public var font: COpaquePointer
  public var cellWidth: Int32 = 0
  public var cellHeight: Int32 = 0
  public var renderer: COpaquePointer
  public var backgroundColor: SDL_Color? = nil
  public let padding: Int32 = 1
  public let doublePadding: Int32 = 2
  public var width = 0             // Max number of horizontal cells.
  public var height = 0            // Max number of vertical cells.
  public var cache = [String: TextureCacheValue]()

  public init(renderer: COpaquePointer, font: COpaquePointer) {
    self.renderer = renderer
    self.font = font
    cellHeight = TTF_FontHeight(font)
    TTF_GlyphMetrics(font, 65, nil, nil, nil, nil, &cellWidth)
  }

  deinit { clearCache() }

  public func clearCache() {
    for (_, v) in cache {
      SDL_DestroyTexture(v.texture)
    }
    cache = [:]
  }

  public func move(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  func hashIt(string: String) -> String {
    return "\(MurmurHash3.hash32(string))"
  }

  public func add(string: String) {
    var k = "\(fontColor.r),\(fontColor.g),\(fontColor.b),\(fontColor.a)."
    if let bg = backgroundColor {
      k += "\(bg.r),\(bg.g),\(bg.b),\(bg.a)."
    } else {
      k += "-,-,-,-."
    }
    k += string.utf16.count > 10 ? hashIt(string) : string
    var value = cache[k]
    if value == nil {
      let surface = backgroundColor != nil ?
        TTF_RenderUTF8_Shaded(font, string, fontColor, backgroundColor!) :
        TTF_RenderUTF8_Blended(font, string, fontColor)
      defer { SDL_FreeSurface(surface) }
      value = TextureCacheValue(
          texture: SDL_CreateTextureFromSurface(renderer, surface),
          width: surface.memory.w, count: string.characters.count, timestamp: 1)
      cache[k] = value
    }
    var destRect = SDL_Rect(x: padding + (Int32(x) * cellWidth),
        y: padding + (Int32(y) * cellHeight), w: value!.width, h: cellHeight)
    SDL_RenderCopy(renderer, value!.texture, nil, &destRect)
    x += value!.count
    value!.timestamp = 1
  }

  public func changeScreenSize(width: Int32, height: Int32) {
    self.width = Int((width - doublePadding) / cellWidth)
    self.height = Int((height - doublePadding) / cellHeight)
  }

}
