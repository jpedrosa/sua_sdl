
import _Sua


class Button: Span {

  var text = Text()

  init(text: String) {
    super.init()
    self.text.text = text
    self.text.style = "%b#FFF,00F="
    add("%#FFF,00F=!!%#FFF,00F= ", self.text, "%#FFF,00F= %#FFF,00F=!!")
  }

}


public class TextField: Span, FocusElement {

  public var descText = Text()
  public var openText = Text()
  public var closeText = Text()
  var openCloseCount = 0

  override init() {
    super.init()
    descText.width = 10
    descText.height = 1
    descText.style = "%u#000,FFC="
    openText.text = "%#000,FFC=[>"
    closeText.text = "%#000,FFC=]"
    openCloseCount = openText.text.utf16.count + closeText.text.utf16.count
    add(openText, descText, closeText)
    on(.MouseDown) { ev in
      self.focus()
      ev.stopImmediatePropagation()
      ev.preventDefault()
    }
  }

  public func _onKeyDown(ev: SEvent) {
    p("key down input")
  }

  public func _onKeyUp(ev: SEvent) {
    p("key up input")
  }

  public func _onTextInput(ev: SEvent) {
    p("text input")
  }

  public func _onFocus(ev: SEvent) {
    p("focus input")
    descText.style = "%u#000,CFC="
    openText.style = "%#000,CFC="
    closeText.style = "%#000,CFC="
  }

  public func _onBlur(ev: SEvent) {
    p("blur input")
    descText.style = "%u#000,FFC="
    openText.style = "%#000,FFC="
    closeText.style = "%#000,FFC="
  }

  public var text: String {
    get { return descText.text }
    set { descText.text = newValue }
  }

  override public func draw(x: Int, y: Int, size: TellSize) {
    super.draw(x, y: y, size: size)
    p("override draw \(size.width - openCloseCount)")
  }

}


public class TextScroller: Text {

  public var offset = -1

  public func step() {
    offset -= 1
    if text.characters.count + offset + lastSize.contentWidth <= 0 {
      offset = -1
    }
  }

  public func drawOffsetText(x: Int, y: Int, startIndex: Int, endIndex: Int) {
    S.textGrid.move(x, y: y)
    S.textGrid.add(text.characters.substring(startIndex, endIndex: endIndex))
  }

  override public func drawContent(x: Int, y: Int, w: Int, len: Int) {
    if offset < 0 {
      var nx = x + w + offset
      var si = 0
      if nx < x {
        si = x - nx
        nx = x
      }
      if si <= len {
        var ei = -offset
        if ei > len {
          ei = len
        }
        drawOffsetText(nx, y: y, startIndex: si, endIndex: ei)
      }
    }
  }

}
