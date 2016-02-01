
import _Sua


public class Text: Element {
  public var type = SType.Text
  public var text = ""

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
  public var lastx = 0
  public var lasty = 0
  public var lastSize = TellSize.EMPTY


  public init() { }

  public func tellSize() -> TellSize {
    var t = TellSize()
    t.element = self
    t.count = text.characters.count
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

  public func draw(x: Int, y: Int, size: TellSize) {
    let w = size.width - size.borderLeft - size.borderRight
    let contentHeight = size.height - size.borderTop - size.borderBottom
    if w <= 0 || contentHeight <= 0 {
      return
    }
    let ap = drawBorder(x, y: y, size: size)
    drawBackground(ap.x, y: ap.y, width: w, height: contentHeight,
        strings: backgroundStrings)
    S.textGrid.move(ap.x, y: ap.y)
    let len = size.count
    if w == len {
      S.textGrid.add(text)
    } else {
      let flen = min(w, len)
      let z = String(text.characters.substring(0, endIndex: flen))
      if align != .Left {
        let n = commonAlign(align, availableWidth: w - flen)
        S.textGrid.move(ap.x + n, y: ap.y)
      }
      S.textGrid.add(z)
    }
  }

}
