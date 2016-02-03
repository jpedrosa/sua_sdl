
import _Sua


public enum VerticalAlign {
  case Top
  case Center
  case Bottom
}


public enum TextAlign {
  case Left
  case Center
  case Right
}


public class Span: Element {
  public var type = SType.Span
  public var children = [Element]()

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
  public var backgroundStrings = [" "]
  public var borderBackgroundColor: Color?
  public var borderColor: Color?
  public var _borderStyle: Int32 = 0
  public var align = TextAlign.Left
  public var verticalAlign = VerticalAlign.Top
  public var lastx = 0
  public var lasty = 0
  public var lastSize = TellSize.EMPTY


  public init() { }

  public func add(args: Any...) {
    addArgs(args)
  }

  public func div(fn: (inout Div) throws -> Void) throws {
    var d = Div()
    try fn(&d)
    children.append(d)
  }

  public func addArgs(args: [Any]) {
    for v in args {
      if v is String {
        let vs = (v as! String)
        do {
          for (s, hc) in try Hexastyle.parseText(vs) {
            let t = Text()
            if let ahc = hc {
              t.updateFromHexastyle(ahc)
            }
            t._text = s
            children.append(t)
          }
        } catch {
          let t = Text()
          t._text = vs
          children.append(t)
        }
      } else if v is Text {
        children.append(v as! Text)
      } else if v is Span {
        children.append(v as! Span)
      } else if v is Div {
        children.append(v as! Div)
      }
    }
  }

  public func tellSize() -> TellSize {
    var t = TellSize()
    t.element = self
    t.children = []
    for e in children {
      let s = e.tellSize()
      t.children!.append(s)
      t.childrenWidth += s.width
      if s.height > t.childrenHeight {
        t.childrenHeight = s.height
      }
      if s.expandWidth {
        t.childWidthExpander += 1
        if s.expandMaxWidth < 0 {
          t.childExpandMaxWidth = -1
        } else if t.childExpandMaxWidth >= 0 {
          t.childExpandMaxWidth += s.expandMaxWidth
        }
      }
      if s.expandHeight {
        t.childWidthExpander = 1
        if s.expandMaxHeight < 0 {
          t.childExpandMaxHeight = -1
        } else if t.childExpandMaxHeight >= 0 &&
            s.expandMaxHeight > t.childExpandMaxHeight {
          t.childExpandMaxHeight = s.expandMaxHeight
        }
      }
      if s.expandParentWidth {
        t.expandParentWidth = true
      }
      if s.expandParentHeight {
        t.expandParentHeight = true
      }
    }
    t.width = width
    if t.childrenWidth > t.width {
      t.width = t.childrenWidth
    }
    t.height = height
    if t.childrenHeight > t.height {
      t.height = t.childrenHeight
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
    t.expandWidth = expandWidth
    t.expandHeight = expandHeight
    if expandParentWidth {
      t.expandParentWidth = true
      t.expandWidth = true
    }
    if expandParentHeight {
      t.expandParentHeight = true
      t.expandHeight = true
    }
    if t.expandWidth {
      t.expandMaxWidth = maxWidth
    }
    if t.expandHeight {
      t.expandMaxHeight = maxHeight
    }
    return t
  }

  public func draw(x: Int, y: Int, size: TellSize) {
    lastx = x
    lasty = y
    lastSize = size
    var w = size.width - size.borderLeft - size.borderRight
    let contentHeight = size.height - size.borderTop - size.borderBottom
    if w <= 0 || contentHeight <= 0 {
      return
    }
    var ap = S.textGrid.withStyle(_borderStyle) { () -> Point in
      return S.textGrid.withColor(borderColor,
          backgroundColor: borderBackgroundColor) { () -> Point in
        return self.drawBorder(x, y: y, size: size)
      }
    }
    var availableWidth = w - size.childrenWidth
    drawBackground(ap.x, y: ap.y, width: w, height: contentHeight,
        strings: backgroundStrings)

    ///////////////////////////// start /////////////////////////////////////
    // This code served as a template for Div's height expanding.
    var childrenList = size.children!
    var widthExpander = size.childWidthExpander
    if widthExpander > 0 {
      var changedChildren = childrenList
      let len = changedChildren.count
      var expanders = [Bool](count: len, repeatedValue: false)
      for i in 0..<len {
        if childrenList[i].expandWidth {
          expanders[i] = true
        }
      }
      while availableWidth > 0 && widthExpander > 0 {
        var widthShare = availableWidth
        if widthExpander > 1 {
          widthShare = availableWidth / widthExpander
          if widthShare == 0 {
            widthShare = 1
          }
        }
        for i in 0..<len {
          let c = changedChildren[i]
          if expanders[i] {
            if c.expandMaxWidth == -1 {
              changedChildren[i].width += widthShare
              availableWidth -= widthShare
            } else if widthShare <= c.expandMaxWidth {
              changedChildren[i].width += widthShare
              changedChildren[i].expandMaxWidth -= widthShare
              availableWidth -= widthShare
            } else if c.expandMaxWidth == 0 {
              widthExpander -= 1
              expanders[i] = false
            }
            if availableWidth == 0 {
              break
            }
          }
        }
      }
      childrenList = changedChildren
      ///////////////////////////// end /////////////////////////////////////
    }

    if align != .Left && size.expandWidth && availableWidth > 0 {
      ap.x += commonAlign(align, availableWidth: availableWidth)
    }

    for s in childrenList {
      var candidateSize = s
      if s.width > w {
        candidateSize.width = w
      }
      if verticalAlign != .Top && s.height < contentHeight {
        let yo = verticalAlign == .Center ? (contentHeight - s.height) / 2 :
            contentHeight - s.height
        s.element!.draw(ap.x, y: ap.y + yo, size: candidateSize)
      } else {
        s.element!.draw(ap.x, y: ap.y, size: candidateSize)
      }
      w -= s.width
      if w <= 0 {
        break
      }
      ap.x += s.width
    }
  }

  public func pointToList(x: Int, y: Int, inout list: [Element]) -> Bool {
    if matchPoint(x, y: y) {
      list.append(self)
      for c in children {
        if c.type == .Text {
          if c.matchPoint(x, y: y) {
            list.append(c)
          }
        } else if c.type == .Div {
          if (c as! Div).pointToList(x, y: y, list: &list) {
            break
          }
        } else if c.type == .Span {
          if (c as! Span).pointToList(x, y: y, list: &list) {
            break
          }
        }
      }
      return true
    }
    return false
  }

}
