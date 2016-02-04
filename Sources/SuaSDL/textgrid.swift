
import Glibc
import CSua
import CSDL
import _Sua


public class TextureCacheValue {
  var texture: COpaquePointer
  var width: Int32
  var xOffset: Int32
  var timestamp: Int

  init(texture: COpaquePointer, width: Int32, xOffset: Int32, timestamp: Int) {
    self.texture = texture
    self.width = width
    self.xOffset = xOffset
    self.timestamp = timestamp
  }

  deinit { SDL_DestroyTexture(texture) }

}


public struct CellPoint {
  var x: Int
  var y: Int
}


public class TextGrid {

  public var x = 0
  public var y = 0
  public var fontColor = Color(r: 0, g: 0, b: 0, a: 255)
  public var font: COpaquePointer
  public var cellWidth: Int32 = 0
  public var cellHeight: Int32 = 0
  public var renderer: COpaquePointer
  public var backgroundColor: Color? = nil
  public let padding: Int32 = 1
  public var width = 0             // Max number of horizontal cells.
  public var height = 0            // Max number of vertical cells.
  public var cache = [String: TextureCacheValue]()
  public var descent: Int32 = 0
  public var colorStack = [Color?]()
  public var styleStack = [Int32]()
  public var style: Int32 = 0

  public init(renderer: COpaquePointer, font: COpaquePointer) {
    self.renderer = renderer
    self.font = font
    cellHeight = TTF_FontHeight(font)
    TTF_GlyphMetrics(font, 65, nil, nil, nil, nil, &cellWidth)
    backgroundColor = Color(r: 255, g: 255, b: 255, a: 255)
    descent = TTF_FontDescent(font)
    // var some = 0
    // TTF_SetFontStyle(font, some) //TTF_STYLE_BOLD | TTF_STYLE_UNDERLINE | TTF_STYLE_STRIKETHROUGH | TTF_STYLE_ITALIC)
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

  func prepareKey(c: UInt16) -> String {
    // Incredibly, long interpolation statements with the code below was causing
    // memory leaks in Swift when in release mode. So we refactored it into this
    // method and broke the statements into smaller blocks in order to appease
    // the compiler.
    var k = String(fontColor.r) +
        "," +
        String(fontColor.g) +
        "," +
        String(fontColor.b) +
        "," +
        String(fontColor.a) +
        "."
    if let bg = backgroundColor {
      k += String(bg.r) +
        "," +
        String(bg.g) +
        ","
      k += String(bg.b) +
        "," +
        String(bg.a) +
        "."
    }
    k += String(style)
    k += "."
    k += String(c)
    return k
  }

  public func add(string: String) {
    let ny = padding + (Int32(y) * cellHeight) + descent
    var nx = padding + (Int32(x) * cellWidth)
    for c in string.utf16 {
      let k = prepareKey(c)
      var value = cache[k]
      if value == nil {
        if style != TTF_GetFontStyle(font) {
          TTF_SetFontStyle(font, style)
        }
        let surface = backgroundColor != nil ?
          TTF_RenderGlyph_Shaded(font, c, fontColor, backgroundColor!) :
          TTF_RenderGlyph_Blended(font, c, fontColor)
        defer { SDL_FreeSurface(surface) }
        var minx: Int32 = 0
        TTF_GlyphMetrics(font, c, &minx, nil, nil, nil, nil)
        // xOffset is for correcting the SDL code that turns negative minx into
        // a positive number. Noticed this for the "╮" top-right border
        // character which has minx -1 with the Dejavu Mono font. SDL turns it
        // into 1 to do its drawing. We use this offset number in the render
        // function a little below.
        value = TextureCacheValue(
            texture: SDL_CreateTextureFromSurface(renderer, surface),
            width: surface.memory.w, xOffset: minx < 0 ? minx : 0, timestamp: 1)
        cache[k] = value
      }
      var destRect = SDL_Rect(x: nx + value!.xOffset, y: ny,
          w: value!.width, h: cellHeight)
      SDL_RenderCopy(renderer, value!.texture, nil, &destRect)
      x += 1
      nx += cellWidth
      value!.timestamp = 1
    }
  }

  public func changeScreenSize(width: Int32, height: Int32) {
    self.width = Int((width - padding) / cellWidth)
    self.height = Int((height - padding) / cellHeight)
  }

  public func pointToCell(x: Int32, y: Int32) -> CellPoint? {
    p("pointToCell \(x) \(y)")
    p(fontColor.toHexa())
    p(fontColor)
    if x >= padding && x <= (cellWidth * Int32(width)) + padding &&
        y >= padding && y <= (cellHeight * Int32(height)) + padding {
      return CellPoint(x: Int((x - padding) / cellWidth),
          y: Int((y - padding) / cellHeight))
    }
    return nil
  }

  public func withColor<Result>(color: Color?, backgroundColor: Color?,
        @noescape fn: () -> Result) -> Result {
    if color == nil && backgroundColor == nil {
      return fn()
    } else {
      let c = color
      let bg = backgroundColor
      colorStack.append(fontColor)
      colorStack.append(self.backgroundColor)
      defer {
        self.backgroundColor = colorStack.removeLast()
        if let ac = colorStack.removeLast() {
          fontColor = ac
        }
      }
      if let ac = c {
        fontColor = ac
      }
      self.backgroundColor = bg
      return fn()
    }
  }

  public func withStyle<Result>(style: Int32,
      @noescape fn: () -> Result) -> Result {
    if style == self.style {
      return fn()
    } else {
      styleStack.append(self.style)
      defer {
        self.style = styleStack.removeLast()
      }
      self.style = style
      return fn()
    }
  }
}
