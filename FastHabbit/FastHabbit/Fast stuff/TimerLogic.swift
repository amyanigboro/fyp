// TimerLogic.swift
import Foundation

/// The one and only place we do countdown formatting + stage math.
///  - displayedTime: “HH:MM:SS remaining” or “+HH:MM:SS overtime”  
///  - flowerStage: 1…5 bloom stage
public struct TimerLogic {
  public let start: Date
  public let end:   Date
  public let now:   Date

  public init(start: Date, end: Date, now: Date) {
    self.start = start
    self.end   = end
    self.now   = now
  }

  /// “HH:MM:SS remaining” if now < end, else “+HH:MM:SS overtime”
  public var displayedTime: String {
    let secondsDiff = now.timeIntervalSince(end)
    let absSecs = Int(abs(secondsDiff).rounded())
    let h = absSecs / 3600
    let m = (absSecs % 3600) / 60
    let s = absSecs % 60
    let fmt = String(format: "%02d:%02d:%02d", h, m, s)
    return secondsDiff < 0
      ? "\(fmt) remaining"
      : "+\(fmt) overtime"
  }

  /// 1…5 based on fraction = (now–start)/(end–start)
  public var flowerStage: Int {
    let total = end.timeIntervalSince(start)
    guard total > 0 else { return 1 }
    let done  = now.timeIntervalSince(start)
    let frac  = max(0, min(1, done/total))
    return min(5, Int(frac * 4) + 1)
  }
}
