
import Glibc
import CSua
import CSDL
import _Sua


public enum SDLError: ErrorType {
  case Init(message: String)
  case CreateWindow(message: String)
  case CreateRenderer(message: String)
  case FontInit(message: String)
  case FontLoad(message: String)
}


public class SDLImpl {

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

  public func start() throws {

    if SDL_Init(UInt32(SDL_INIT_VIDEO)) < 0 {
      throw SDLError.Init(message: errorMessage)
    }

    defer { SDL_Quit() }

    let win = SDL_CreateWindow("Hello World!", 100, 100, 640, 480,
        SDL.WINDOW_SHOWN | SDL.WINDOW_RESIZABLE)

    if win == nil {
      throw SDLError.CreateWindow(message: errorMessage)
    }

    defer { SDL_DestroyWindow(win) }

    let rend = SDL_CreateRenderer(win, -1, SDL.RENDERER_ACCELERATED)
    // let rend = SDL_CreateRenderer(win, -1, 0)

    if rend == nil {
      throw SDLError.CreateRenderer(message: errorMessage)
    }

    if TTF_Init() == -1 {
      throw SDLError.FontInit(message: errorMessage)
    }

    defer { TTF_Quit() }

    let fontPath = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"

    let freeSans = TTF_OpenFont(fontPath, 12)

    if freeSans == nil {
      throw SDLError.FontLoad(message: errorMessage)
    }

    // TTF_SetFontHinting(freeSans, TTF_HINTING_NONE)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_MONO)
    TTF_SetFontHinting(freeSans, TTF_HINTING_LIGHT)
    // TTF_SetFontHinting(freeSans, TTF_HINTING_NORMAL)

    //TTF_SetFontStyle(freeSans, TTF_STYLE_BOLD)

    let textGrid = TextGrid(renderer: rend, font: freeSans)

    let redColor = SDL_Color(r: 255, g: 0, b: 0, a: 255)
    let blackColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)
    let yellowColor = SDL_Color(r: 255, g: 255, b: 0, a: 255)
    let blueColor = SDL_Color(r: 0, g: 0, b: 255, a: 255)

    func drawAgain() {
      textGrid.move(10, y: 1)
      textGrid.fontColor = blueColor
      textGrid.add("Hello SuaSDL!")
      textGrid.fontColor = blackColor
      textGrid.move(1, y: 10)
      textGrid.add("Leo")
      textGrid.add("nardo")
      textGrid.add("Voador")
      textGrid.move(1, y: 11)
      textGrid.add("surfaceMsg 0x0000000001971750")
      textGrid.move(1, y: 12)
      textGrid.add("Coração do João")
      textGrid.move(1, y: 13)
      textGrid.add("A")
      textGrid.add("b")
      textGrid.add("C")
      textGrid.add("d")
      textGrid.add("E")
      textGrid.add("f")
      textGrid.move(0, y: 14)
      textGrid.add("Gabriel")
      textGrid.move(1, y: 20)
      textGrid.fontColor = redColor
      textGrid.backgroundColor = yellowColor
      textGrid.add("╭───────────────────────────────────────────╮")
      textGrid.move(1, y: 21)
      textGrid.add("│                                           │")
      textGrid.move(1, y: 22)
      textGrid.add("╰───────────────────────────────────────────╯")
      textGrid.fontColor = blackColor
      textGrid.backgroundColor = nil
    }

    var ev = SDL_Event()
    var done = false
    var invalidated = false
    var lastWidth: Int32 = -1
    var lastHeight: Int32 = -1

    while !done {
      while SDL_PollEvent(&ev) != 0 {
        invalidated = true
        if ev.type == WINDOWEVENT {
//          p("window event \(ev.window.event)")
        } else if ev.type == TEXTINPUT {
          p("text input \(ev.text)")
        } else if ev.type == QUIT {
          done = true
        }
      }
      if invalidated {
        var w: Int32 = 0
        var h: Int32 = 0
        SDL_GetWindowSize(win, &w, &h)
        if w != lastWidth || h != lastHeight {
          lastWidth = w
          lastHeight = h
          textGrid.changeScreenSize(w, height: h)
        }
        SDL_SetRenderDrawColor(rend, 255, 255, 255, 255)
        SDL_RenderClear(rend)
        drawAgain()
        SDL_RenderPresent(rend)
        invalidated = false
      }
      SDL_Delay(100)
    //   SDL_Delay(16)
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


public let SDL = SDLImpl()


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

  public init(renderer: COpaquePointer, font: COpaquePointer) {
    self.renderer = renderer
    self.font = font
    cellHeight = TTF_FontHeight(font)
    TTF_GlyphMetrics(font, 65, nil, nil, nil, nil, &cellWidth)
  }

  public func move(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  public func add(string: String) {
    let ny = Int32(y) * cellHeight
    let surface = backgroundColor != nil ?
        TTF_RenderUTF8_Shaded(font, string, fontColor, backgroundColor!) :
        TTF_RenderUTF8_Blended(font, string, fontColor)
    defer { SDL_FreeSurface(surface) }
    let texture = SDL_CreateTextureFromSurface(renderer, surface)
    defer { SDL_DestroyTexture(texture) }
    var textureRect = SDL_Rect(x: padding + (Int32(x) * cellWidth),
        y: padding + ny, w: surface.memory.w, h: surface.memory.h)
    SDL_RenderCopy(renderer, texture, nil, &textureRect)
    x += string.characters.count
  }

  public func changeScreenSize(width: Int32, height: Int32) {
    self.width = Int((width - doublePadding) / cellWidth)
    self.height = Int((height - doublePadding) / cellHeight)
  }

}
