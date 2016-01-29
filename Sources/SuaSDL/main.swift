
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

let fontPath = "/usr/share/fonts/truetype/freefont/FreeSans.ttf"
let freeSans = TTF_OpenFont(fontPath, 48)

if freeSans == nil {
  throw SDLError.FontLoad
}

let fontColor = SDL_Color(r: 0, g: 0, b: 255, a: 255)

// Blended version does anti-aliasing, finally!
let surfaceMsg = TTF_RenderText_Blended(freeSans, "Hello World!", fontColor)
//let surfaceMsg = TTF_RenderText_Solid(freeSans, "Hello World!", fontColor)

let msg = SDL_CreateTextureFromSurface(rend, surfaceMsg)

SDL_FreeSurface(surfaceMsg)

let textWidth = surfaceMsg.memory.w
let textHeight = surfaceMsg.memory.h

var msgRect = SDL_Rect(x: 10, y: 10, w: textWidth, h: textHeight)

let msgResult = SDL_RenderCopy(rend, msg, nil, &msgRect)

//SDL_DestroyTexture(msg)

p("msgResult \(msgResult)")

p("surfaceMsg \(surfaceMsg)")

p("font \(freeSans)")

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
//  gTextTexture.render( ( SCREEN_WIDTH - gTextTexture.getWidth() ) / 2, ( SCREEN_HEIGHT - gTextTexture.getHeight() ) / 2 );
  SDL_RenderPresent(rend)
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
