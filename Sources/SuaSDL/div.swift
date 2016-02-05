
import _Sua


public class Div: Element {
  public var type = SType.Div
  public var children = [Span]()

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
  public var lastx = 0
  public var lasty = 0
  public var lastSize = TellSize.EMPTY
  public var eventStore: EventStore?


  public init() { }

  public func span(args: Any...,
      fn: ((inout Span) throws -> Void)? = nil) throws {
    var span = Span()
    span.addArgs(args)
    if let af = fn {
      try af(&span)
    }
    children.append(span)
  }

  public func tellSize() -> TellSize {
    var t = TellSize()
    t.element = self
    t.children = []
    for e in children {
      let s = e.tellSize()
      t.children!.append(s)
      if s.width > t.childrenWidth {
        t.childrenWidth = s.width
      }
      t.childrenHeight += s.height
      if s.expandWidth {
        t.childWidthExpander = 1
        if s.expandMaxWidth < 0 {
          t.childExpandMaxWidth = -1
        } else if t.childExpandMaxWidth >= 0 &&
            s.expandMaxWidth > t.childExpandMaxWidth {
          t.childExpandMaxWidth = s.expandMaxWidth
        }
      }
      if s.expandHeight {
        t.childHeightExpander += 1
        if s.expandMaxHeight < 0 {
          t.childExpandMaxHeight = -1
        } else if t.childExpandMaxHeight >= 0 {
          t.childExpandMaxHeight += s.expandMaxHeight
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
    t.expandWidth = expandWidth
    t.expandHeight = expandHeight
    if t.expandParentWidth {
      t.expandParentWidth = true
      t.expandWidth = true
    } else if expandParentWidth {
      t.expandParentWidth = true
    }
    if t.expandParentHeight {
      t.expandParentHeight = true
      t.expandHeight = true
    } else if expandParentHeight {
      t.expandParentHeight = true
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
    let w = size.contentWidth
    var contentHeight = size.contentHeight
    if w <= 0 || contentHeight <= 0 {
      return
    }
    var ap = S.textGrid.withColor(borderColor,
        backgroundColor: borderBackgroundColor) { () -> Point in
      return self.drawBorder(x, y: y, size: size)
    }
    drawBackground(ap.x, y: ap.y, width: w, height: contentHeight,
        strings: backgroundStrings)

    ///////////////////////////// start /////////////////////////////////////
    // This code is similar to Span's width, except that it deals with height.
    var availableHeight = contentHeight - size.childrenHeight
    var childrenList = size.children!
    var heightExpander = size.childHeightExpander
    if heightExpander > 0 {
      var changedChildren = childrenList
      let len = changedChildren.count
      var expanders = [Bool](count: len, repeatedValue: false)
      for i in 0..<len {
        if childrenList[i].expandHeight {
          expanders[i] = true
        }
      }
      while availableHeight > 0 && heightExpander > 0 {
        var heightShare = availableHeight
        if heightExpander > 1 {
          heightShare = availableHeight / heightExpander
          if heightShare == 0 {
            heightShare = 1
          }
        }
        for i in 0..<len {
          let c = changedChildren[i]
          if expanders[i] {
            if c.expandMaxHeight == -1 {
              changedChildren[i].height += heightShare
              availableHeight -= heightShare
            } else if heightShare <= c.expandMaxHeight {
              changedChildren[i].height += heightShare
              changedChildren[i].expandMaxHeight -= heightShare
              availableHeight -= heightShare
            } else if c.expandMaxHeight == 0 {
              heightExpander -= 1
              expanders[i] = false
            }
            if availableHeight == 0 {
              break
            }
          }
        }
      }
      childrenList = changedChildren
    }
    /////////////////////////////  end  /////////////////////////////////////

    for s in childrenList {
      var candidateSize = s
      if s.height > contentHeight {
        candidateSize.height = contentHeight
      }
      if s.expandWidth {
        let mw = s.expandMaxWidth
        candidateSize.width = mw >= 0 ? min(w, mw) : w
      } else if s.width > w {
        candidateSize.width = w
      }
      s.element!.draw(ap.x, y: ap.y, size: candidateSize)
      ap.y += s.height
      contentHeight -= s.height
      if contentHeight <= 0 {
        break
      }
    }
  }

  public func mainDraw(x: Int, y: Int, width: Int, height: Int) {
    var size = tellSize()
    if expandWidth {
      size.width = width
    }
    if expandHeight {
      size.height = height
    }
    draw(x, y: y, size: size)
  }

  public func pointToList(x: Int, y: Int, inout list: [Element]) -> Bool {
    if matchPoint(x, y: y) {
      list.append(self)
      for c in children {
        if c.pointToList(x, y: y, list: &list) {
          break
        }
      }
      return true
    }
    return false
  }

}
