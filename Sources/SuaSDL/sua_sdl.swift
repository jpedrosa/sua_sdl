
import Glibc
import CSua
import CSDL
import _Sua


enum SDLError: ErrorType {
  case Init(message: String)
  case CreateWindow
  case CreateRenderer
  case FontInit
  case FontLoad
}


class SDLImpl {

  let WINDOW_SHOWN: UInt32 = 4
  let QUIT: UInt32         = 256
  let WINDOWEVENT: UInt32  = 512
  let TEXTINPUT: UInt32    = 771

  let WINDOWEVENT_CLOSE: UInt8 = 214

  let WINDOW_RESIZABLE: UInt32 = 32

  let KEY_DOWN: UInt16 = 768
  let KEY_UP: UInt16   = 769

  let RENDERER_ACCELERATED: UInt32 = 2

  func start() throws {

    if SDL_Init(UInt32(SDL_INIT_VIDEO)) < 0 {
      throw SDLError.Init(message: "\(SDL_GetError())")
    }

    defer { SDL_Quit() }

    let win = SDL_CreateWindow("Hello World!", 100, 100, 640, 480,
        SDL.WINDOW_SHOWN | SDL.WINDOW_RESIZABLE)

    if win == nil {
      throw SDLError.CreateWindow
    }

    defer { SDL_DestroyWindow(win) }

    let rend = SDL_CreateRenderer(win, -1, SDL.RENDERER_ACCELERATED)
    // let rend = SDL_CreateRenderer(win, -1, 0)

    if rend == nil {
      throw SDLError.CreateRenderer
    }

    if TTF_Init() == -1 {
      throw SDLError.FontInit
    }

    defer { TTF_Quit() }

    let fontPath = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"

    let freeSans = TTF_OpenFont(fontPath, 12)

    if freeSans == nil {
      throw SDLError.FontLoad
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
        if ev.type == SDL.TEXTINPUT {
          p("text input \(ev.text)")
        } else if ev.type == SDL.QUIT {
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

}


let SDL = SDLImpl()


class TextGrid {

  var x = 0
  var y = 0
  var fontColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)
  var font: COpaquePointer
  var cellWidth: Int32 = 0
  var cellHeight: Int32 = 0
  var renderer: COpaquePointer
  var backgroundColor: SDL_Color? = nil
  let padding: Int32 = 1
  let doublePadding: Int32 = 2
  var width = 0             // Max number of horizontal cells.
  var height = 0            // Max number of vertical cells.

  init(renderer: COpaquePointer, font: COpaquePointer) {
    self.renderer = renderer
    self.font = font
    cellHeight = TTF_FontHeight(font)
    TTF_GlyphMetrics(font, 65, nil, nil, nil, nil, &cellWidth)
  }

  func move(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  func add(string: String) {
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

  func changeScreenSize(width: Int32, height: Int32) {
    self.width = Int((width - doublePadding) / cellWidth)
    self.height = Int((height - doublePadding) / cellHeight)
  }

}