
import Glibc
import CSua
import CSDL
import _Sua


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

}


let SDL = SDLImpl()


enum SDLError: ErrorType {
  case Init(message: String)
  case CreateWindow
  case CreateRenderer
  case FontInit
  case FontLoad
}


class TextGrid {

  var x = 0
  var y = 0
  var fontColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)
  var font: COpaquePointer
  var cellWidth: Int32 = 0
  var cellHeight: Int32 = 0
  var renderer: COpaquePointer
  let backgroundColor = SDL_Color(r: 255, g: 255, b: 255, a: 255)

  init(renderer: COpaquePointer, font: COpaquePointer) {
    self.renderer = renderer
    self.font = font
    cellHeight = TTF_FontHeight(font)
//    TTF_SizeText(font, "W", &cellWidth, &cellHeight)
  //  p("cellWidth \(cellWidth)")
//    var minx: Int32 = 0
  //  var maxx: Int32 = 0
    //var advance: Int32 = 0
//    TTF_GlyphMetrics(font, 65, &minx, &maxx, nil, nil, &cellWidth)
    TTF_GlyphMetrics(font, 65, nil, nil, nil, nil, &cellWidth)
    //p("minx \(minx), maxx \(maxx), advance \(advance)")
  }

  func move(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  func add(string: String) {
    let ny = Int32(y) * cellHeight
    // let surface = TTF_RenderUTF8_Shaded(font, string, fontColor,
    //     backgroundColor)
    let surface = TTF_RenderUTF8_Blended(font, string, fontColor)
    defer { SDL_FreeSurface(surface) }
    let texture = SDL_CreateTextureFromSurface(renderer, surface)
    defer { SDL_DestroyTexture(texture) }
    var textureRect = SDL_Rect(x: Int32(x) * cellWidth, y: ny,
        w: surface.memory.w, h: surface.memory.h)
    SDL_RenderCopy(renderer, texture, nil, &textureRect)
    x += string.characters.count
  }

}


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

// let rend = SDL_CreateRenderer(win, -1, SDL.RENDERER_ACCELERATED)
let rend = SDL_CreateRenderer(win, -1, 0)

if rend == nil {
  throw SDLError.CreateRenderer
}

// SDL_SetRenderDrawColor(rend, 255, 255, 255, 255)
// SDL_RenderClear(rend)
// SDL_RenderPresent(rend)

p("Hello SDL!")

if TTF_Init() == -1 {
  throw SDLError.FontInit
}

defer { TTF_Quit() }

// let fontPath = "/usr/share/fonts/truetype/freefont/FreeMono.ttf"
let fontPath = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
//let fontPath = "/usr/share/fonts/truetype/droid/DroidSansMono.ttf"
//let fontPath = "/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf"
//let fontPath = "/usr/share/fonts/truetype/tlwg/TlwgMono.ttf"
// let fontPath = "/usr/share/fonts/truetype/ubuntu-font-family/UbuntuMono-R.ttf"
let freeSans = TTF_OpenFont(fontPath, 12)

if freeSans == nil {
  throw SDLError.FontLoad
}

// TTF_SetFontHinting(freeSans, TTF_HINTING_NONE)
// TTF_SetFontHinting(freeSans, TTF_HINTING_MONO)
TTF_SetFontHinting(freeSans, TTF_HINTING_LIGHT)
// TTF_SetFontHinting(freeSans, TTF_HINTING_NORMAL)

TTF_SetFontStyle(freeSans, TTF_STYLE_BOLD)

let textGrid = TextGrid(renderer: rend, font: freeSans)

var sizeWidth: Int32 = 0
var sizeHeight: Int32 = 0

TTF_SizeUNICODE(freeSans, Array("Coração".utf16), &sizeWidth, &sizeHeight)

p("size width \(sizeWidth) height \(sizeHeight)")

p("font height \(TTF_FontHeight(freeSans))")

p("font ascent \(TTF_FontAscent(freeSans)) descent \(TTF_FontDescent(freeSans))")

p("font line skip \(TTF_FontLineSkip(freeSans))")

let fontColor = SDL_Color(r: 0, g: 0, b: 255, a: 255)

let shadowColor = SDL_Color(r: 0, g: 0, b: 0, a: 255)

// Blended version does anti-aliasing, finally!
//let surfaceMsg = TTF_RenderText_Blended(freeSans, "Hello World!", fontColor)
let surfaceMsg = TTF_RenderUTF8_Blended(freeSans, "Hello ção World!", fontColor)
// let surfaceMsg = TTF_RenderText_Shaded(freeSans, "Hello ção World!", fontColor,
//     shadowColor)
//let surfaceMsg = TTF_RenderText_Solid(freeSans, "Hello World!", fontColor)

// SDL_SaveBMP_RW(surfaceMsg, SDL_RWFromFile("/home/dewd/t_/hello_sdl.bmp", "wb"), 1)

let msg = SDL_CreateTextureFromSurface(rend, surfaceMsg)

SDL_FreeSurface(surfaceMsg)

let textWidth = surfaceMsg.memory.w
let textHeight = surfaceMsg.memory.h

var msgRect = SDL_Rect(x: 10, y: 10, w: textWidth, h: textHeight)

// let msgResult = SDL_RenderCopy(rend, msg, nil, &msgRect)

//SDL_DestroyTexture(msg)

// p("msgResult \(msgResult)")

p("surfaceMsg \(surfaceMsg)")

p("font \(freeSans)")

func drawAgain() {
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
}

var ev = SDL_Event()
var done = false

while !done {
  while SDL_PollEvent(&ev) != 0 {
    if ev.type == SDL.TEXTINPUT {
      p("text input \(ev.text)")
    } else if ev.type == SDL.QUIT {
      done = true
    }
  }
  SDL_SetRenderDrawColor(rend, 255, 255, 255, 255)
  SDL_RenderClear(rend)
  let msgResult = SDL_RenderCopy(rend, msg, nil, &msgRect)
  drawAgain()
  SDL_RenderPresent(rend)
  SDL_Delay(100)
//   SDL_Delay(16)
}

// while true {
//   SDL_WaitEvent(&ev)
//   p("ev \(ev.type)")
//   if ev.type == SDL.WINDOWEVENT {
//     p("window even \(ev.window.event)")
//   } else if ev.type == SDL.QUIT {
//     p("sql wants out")
//     break
//   }
//   if ev.type == SDL.WINDOWEVENT && ev.window.event == SDL.WINDOWEVENT_CLOSE {
//     p("out of window we go")
//     break
//   }
// }

p("about to quit")
