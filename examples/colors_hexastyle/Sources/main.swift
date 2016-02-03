
import Glibc
import CSua
import CSDL
import _Sua
import SuaSDL


try S.start() { div in
  S.mainDiv.borderTop = true
  S.mainDiv.borderRight = true
  S.mainDiv.borderBottom = true
  S.mainDiv.borderLeft = true
  try div.span("%u#F00=Hexa%u#0F0=st%u#00F=yle")
  try div.span("%#0F0,000=S%#8ef,000=u%#EE0,000=a")
  var o = Text()
  o.backgroundColor = Color(r: 255, g: 0, b: 0, a: 255)
  o.borderColor = Color(r: 125, g: 125, b: 125, a: 255)
  o.text = "OVNI"
  o.borderTop = true
  o.borderBottom = true
  o.borderLeft = true
  o.borderRight = true
  try div.span("Water", "Ice", "Fire", o) { span in
    span.verticalAlign = .Center
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
  }
  try div.span("Second row!")
  try div.span("Third and here we are!")
  try div.span("Maxwell")
  try div.span("Disk")
  var clip = Text()
  clip.color = Color(r: 255, g: 255, b: 255, a: 255)
  clip.backgroundColor = Color(r: 0, g: 0, b: 255, a: 255)
  clip.borderBackgroundColor = Color(r: 255, g: 255, b: 0, a: 255)
  clip.text = "CLIPPED"
  clip.borderTop = true
  clip.borderRight = true
  clip.borderBottom = true
  clip.borderLeft = true
  clip.maxWidth = 5
  try div.span(clip)
  var spanClip = Span()
  var tryMsg = Text()
  tryMsg.text = "Try and you might get it."
  tryMsg.borderTop = true
  tryMsg.style = "%b#="
  spanClip.add(tryMsg)
  spanClip.maxWidth = 10
  spanClip.add("[For realz!]")
  try div.span(spanClip)
  try div.span("Santo Amaro foi um município até 1935, quando foi anexado a São Paulo.  A sede do munícipio conhecida pela comunidade santo amarense como Casa Amarela (foto) hoje abriga o Paço Cultural Júlio Guerra, no coração do Largo 13 e vizinho ao coreto.")
  try div.span("Employee") { span in
    span.align = .Center
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    span.expandWidth = true
  }
  var space = Text()
  space.text = "%b#fff,00f=Space"
  p("space mars and back \(inspect(space.style))")
  space.expandWidth = true
  try div.span(space, "Customers") { span in
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    span.expandWidth = true
  }
  var leftSpace = Text()
  leftSpace.expandWidth = true
  var rightSpace = Text()
  rightSpace.text = ""
  rightSpace.expandWidth = true
  try div.span(leftSpace, "Victory!", rightSpace) { span in
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    span.expandWidth = true
  }
  var align = Text()
  align.bold = true
  align.underline = true
  align.italic = true
  align.strikethrough = true
  align.text = "Align Me"
  align.align = .Center
  align.expandWidth = true
  try div.span(align) { span in
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    span.expandWidth = true
    span.borderStyle = "%#8B4513,E5E5E5="
  }
  try div.span("Leo")
  try div.span("[=Goodness=]") { span in
    // span.backgroundStrings = ["TextArea"]
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    // span.expandWidth = true
    span.expandHeight = true
  }
  try div.span("Mirror") { span in
    //span.backgroundStrings = ["TextArea"]
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    // span.expandWidth = true
    // span.expandHeight = true
    try span.div { div in
      try div.span("Embedded")
      try div.span("Second line embedded")
    }
  }
  try div.span("Device") { span in
    span.width = 20
    span.backgroundStrings = ["Practical"]
    span.borderTop = true
    span.borderBottom = true
    span.borderLeft = true
    span.borderRight = true
    span.expandHeight = true
    span.borderStyle = "%bsu#="
  }
  try div.span("zinho")
}
