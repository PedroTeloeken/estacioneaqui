//
//  PulseConsoleShake.swift
//  EstacioneAqui
//


import SwiftUI
import UIKit

#if DEBUG

import PulseUI

extension UIDevice {
    static let didShakeNotification = Notification.Name("EstacioneAqui.deviceDidShake")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: UIDevice.didShakeNotification, object: nil)
    }
}

@MainActor
final class PulseConsolePresenter: NSObject, UIAdaptivePresentationControllerDelegate {
    static let shared = PulseConsolePresenter()

    private var window: UIWindow?
    private var observer: NSObjectProtocol?

    private override init() {}

    func startListening() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.didShakeNotification,
            object: nil,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated { PulseConsolePresenter.shared.toggle() }
        }
    }

    private func toggle() {
        if window == nil { present() } else { dismiss() }
    }

    private func present() {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }

        guard let scene else { return }

        let host = UIViewController()
        host.view.backgroundColor = .clear

        let window = PassthroughWindow(windowScene: scene)
        window.rootViewController = host
        window.backgroundColor = .clear
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        self.window = window

        let console = UIHostingController(rootView: NavigationStack { ConsoleView() })
        console.modalPresentationStyle = .pageSheet
        console.presentationController?.delegate = self
        host.present(console, animated: true)
    }

    private func dismiss() {
        window?.rootViewController?.dismiss(animated: true) { [weak self] in
            self?.tearDownWindow()
        }
    }

    nonisolated func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        MainActor.assumeIsolated { tearDownWindow() }
    }

    private func tearDownWindow() {
        window?.isHidden = true
        window = nil
    }
}

private final class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === rootViewController?.view ? nil : hit
    }
}

#endif

extension View {
    func pulseConsoleOnShake() -> some View {
        #if DEBUG
        onAppear { PulseConsolePresenter.shared.startListening() }
        #else
        self
        #endif
    }
}
