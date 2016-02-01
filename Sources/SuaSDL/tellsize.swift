

public enum SType {
  case Div
  case Span
  case Text
}


public enum BorderType {
  case LightCurved
}


public struct Point {
  public var x: Int
  public var y: Int

  static let far = Point(x: -10000, y: 0)
}


public struct TellSize {
  public var width = 0
  public var height = 0
  public var expandWidth = false
  public var expandMaxWidth = 0
  public var expandHeight = false
  public var expandMaxHeight = 0
  public var expandParentWidth = false
  public var expandParentHeight = false
  public var childrenWidth = 0
  public var childWidthExpander = 0
  public var childExpandMaxWidth = 0
  public var childrenHeight = 0
  public var childHeightExpander = 0
  public var childExpandMaxHeight = 0
  public var element: Element?
  public var children: [TellSize]?

  public var count = 0                 // Useful to record NCText's char count.
  public var borderTop = 0       // Store these for the drawing command.
  public var borderRight = 0
  public var borderBottom = 0
  public var borderLeft = 0

  public static let EMPTY = TellSize()
}
