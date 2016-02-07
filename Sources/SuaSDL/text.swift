
import _Sua


public class Text: Element {
  public var type = SType.Text
  public var _text = ""

  public var maxWidth = -1
  public var maxHeight = -1
  public var width = -1
  public var height = -1
  public var borderTop = false
  public var borderRight = false
  public var borderBottom = false
  public var borderLeft = false
  public var borderType = BorderType.LightCurved
  public var expandWidth = false
  public var expandHeight = false
  public var expandParentWidth = false
  public var expandParentHeight = false
  public var align = TextAlign.Left
  public var backgroundStrings = [" "]
  public var backgroundColor: Color?
  public var color: Color?
  public var borderBackgroundColor: Color?
  public var borderColor: Color?
  public var _style: Int32 = 0
  public var _borderStyle: Int32 = 0
  public var lastx = 0
  public var lasty = 0
  public var lastSize = TellSize.EMPTY
  public var eventStore: EventStore?


  public init() { }

  public func tellSize() -> TellSize {
    var t = TellSize()
    t.element = self
    t.count = _text.characters.count
    if width > 0 {
      t.width = width
    } else {
      t.width = t.count
    }
    if t.width > 0 {
      if borderRight {
        t.borderRight = 1
        t.width += 1
      }
      if borderLeft {
        t.borderLeft = 1
        t.width += 1
      }
    }
    if maxWidth >= 0 && t.width > maxWidth {
      t.width = maxWidth
    }
    if height > 0 {
      t.height = height
    } else if t.count > 0 {
      t.height = 1
    }
    if t.height > 0 {
      if borderTop {
        t.borderTop = 1
        t.height += 1
      }
      if borderBottom {
        t.borderBottom = 1
        t.height += 1
      }
    }
    if maxHeight >= 0 && t.height > maxHeight {
      t.height = maxHeight
    }
    if expandWidth {
      t.expandWidth = true
      t.expandMaxWidth = maxWidth
    }
    if expandHeight {
      t.expandHeight = true
      t.expandMaxHeight = maxHeight
    }
    if expandParentWidth {
      t.expandParentWidth = true
    }
    if expandParentHeight {
      t.expandParentHeight = true
    }
    return t
  }

  public func drawContent(x: Int, y: Int, w: Int, len: Int) {
    S.textGrid.move(x, y: y)
    if w == len {
      S.textGrid.add(self._text)
    } else {
      let flen = min(w, len)
      let z = String(self._text.characters.substring(0, endIndex: flen))
      if self.align != .Left {
        let n = self.commonAlign(self.align, availableWidth: w - flen)
        S.textGrid.move(x + n, y: y)
      }
      S.textGrid.add(z)
    }
  }

  public func draw(x: Int, y: Int, size: TellSize) {
    lastx = x
    lasty = y
    lastSize = size
    let w = size.contentWidth
    let contentHeight = size.contentHeight
    if w <= 0 || contentHeight <= 0 {
      return
    }
    let ap = S.textGrid.withColor(borderColor,
        backgroundColor: borderBackgroundColor) { () -> Point in
      return self.drawBorder(x, y: y, size: size)
    }
    S.textGrid.withStyle(_style) {
      S.textGrid.withColor(color, backgroundColor: backgroundColor) {
        self.drawBackground(ap.x, y: ap.y, width: w, height: contentHeight,
            strings: self.backgroundStrings)
        drawContent(ap.x, y: ap.y, w: w, len: size.count)
      }
    }
  }

  func doSetStyleBit(bit: Int32, enabled: Bool) {
    if enabled {
      _style |= bit
    } else {
      _style &= ~bit
    }
  }

  public var bold: Bool {
    get { return (_style & S.BOLD) > 0 }
    set { doSetStyleBit(S.BOLD, enabled: newValue) }
  }

  public var underline: Bool {
    get { return (_style & S.UNDERLINE) > 0 }
    set { doSetStyleBit(S.UNDERLINE, enabled: newValue) }
  }

  public var italic: Bool {
    get { return (_style & S.ITALIC) > 0 }
    set { doSetStyleBit(S.ITALIC, enabled: newValue) }
  }

  public var strikethrough: Bool {
    get { return (_style & S.STRIKETHROUGH) > 0 }
    set { doSetStyleBit(S.STRIKETHROUGH, enabled: newValue) }
  }

  public func updateFromHexastyle(hc: Hexastyle) {
    _style = hc.toSStyle()
    if let ac = hc.color {
      color = Color(r: ac.r, g: ac.g, b: ac.b,
          a: ac.a != nil ? ac.a! : 255)
    } else {
      color = nil
    }
    if let ac = hc.backgroundColor {
      backgroundColor = Color(r: ac.r, g: ac.g, b: ac.b,
          a: ac.a != nil ? ac.a! : 255)
    } else {
      backgroundColor = nil
    }
  }

  public var text: String {
    get { return _text }
    set {
      var s = newValue
      if !s.isEmpty && s.utf16.codeUnitAt(0) == 37 { // %
        do {
          let a = s.bytes
          let len = a.count
          let (hc, advi) = try Hexastyle.parseHexastyle(a, startIndex: 1,
              maxBytes: len)
          if let ahc = hc {
            updateFromHexastyle(ahc)
            let i = advi + 1
            if i < len {
              if let z = String.fromCharCodes(a, start: i, end: len - 1) {
                s = z
              }
            } else {
              s = ""
            }
          }
        } catch {
          // Ignore.
        }
      }
      _text = s
    }
  }

  public var style: String {
    get {
      var s = "%"
      if bold { s += "b" }
      if underline { s += "u" }
      if strikethrough { s += "s" }
      if italic { s += "i" }
      s += "#"
      var gotColor = false
      if let ac = color {
        s += ac.toHexa()
        gotColor = true
      }
      if let ac = backgroundColor {
        if !gotColor {
          s += S.textGrid.fontColor.toHexa()
        }
        s += ","
        s += ac.toHexa()
      }
      s += "="
      return s
    }
    set {
      _style = 0
      color = nil
      backgroundColor = nil
      do {
        let a = newValue.bytes
        let (hc, _) = try Hexastyle.parseHexastyle(a, startIndex: 1,
            maxBytes: a.count)
        if let ahc = hc {
          updateFromHexastyle(ahc)
        } else { // Show text in bold red to indicate error.
          bold = true
          color = Color.red
        }
      } catch {
        bold = true // Show text in bold red to indicate error.
        color = Color.red
      }
    }
  }

}
