import Flutter
import UIKit

public class KeyboardSizePeekPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterEventChannel(
      name: "keyboard_size_peek/events",
      binaryMessenger: registrar.messenger()
    )
    let instance = KeyboardSizePeekPlugin()
    channel.setStreamHandler(instance)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    self.eventSink = events
    let nc = NotificationCenter.default
    nc.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: UIResponder.keyboardWillShowNotification,
      object: nil
    )
    nc.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: UIResponder.keyboardWillHideNotification,
      object: nil
    )
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    self.eventSink = nil
    return nil
  }

  @objc private func keyboardWillShow(_ note: Notification) {
    guard let info = note.userInfo else { return }
    let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
    let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
    eventSink?([
      "height": Double(endFrame.height),
      "durationMs": Int(duration * 1000),
    ])
  }

  @objc private func keyboardWillHide(_ note: Notification) {
    guard let info = note.userInfo else { return }
    let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0
    eventSink?([
      "height": 0.0,
      "durationMs": Int(duration * 1000),
    ])
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
