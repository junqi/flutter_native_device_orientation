import Foundation
import Flutter

class DisplayOrientationListener: OrientationListener {
  init(callback: @escaping (String) -> Void) {
    self.callback = callback
  }
  
  private let callback: ((String) -> Void)
  private var lastOrientation: String?
  
  func start() ->FlutterError? {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(DisplayOrientationListener.receiveOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    return nil;
  }
  
  func stop() {
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.removeObserver(self)
  }
  
  func once() -> FlutterError? {
    callback(getDeviceOrientation())
    return nil
  }
  
  private func getDeviceOrientation() -> String {
    switch (UIDevice.current.orientation) {
    case .portrait:
      return PORTRAIT_UP
    case .portraitUpsideDown:
      return PORTRAIT_DOWN
    case .landscapeRight:
      return LANDSCAPE_RIGHT
    case .landscapeLeft:
      return LANDSCAPE_LEFT
    default:
      return UNKNOWN
    }
  }
  
  @objc private func receiveOrientationChange() {
    let orientation = getDeviceOrientation()
    
    if orientation != lastOrientation {
      lastOrientation = orientation
      callback(orientation)
    }
  }
}
