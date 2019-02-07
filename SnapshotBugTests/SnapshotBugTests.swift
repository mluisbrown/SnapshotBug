import XCTest
@testable import SnapshotBug
import ReactiveCocoa
import ReactiveSwift
import SnapshotTesting

class SnapshotBugTests: XCTestCase {

    func testViewController() {
        Device.all.forEach { device in
//            autoreleasepool {
                let viewController = UIViewController()

                let exp = expectation(description: "\(#file):\(#line)")
                var window: UIWindow! = nil
                let navigation = UINavigationController(rootViewController: viewController)

                viewController.reactive.signal(for: #selector(viewController.viewDidAppear(_:)))
                    .observe(on: QueueScheduler.main)
                    .take(duringLifetimeOf: viewController)
                    .observeValues { _ in
                        exp.fulfill()
                }

                DispatchQueue.main.async {
                    window = self.makeWindow(for: navigation, device: device)
                }

                waitForExpectations(timeout: 5, handler: nil)
                verify(view: window, for: device)
//            }
        }
    }

    func verify(
        view: UIView,
        for device: Device,
        file: StaticString = #file,
        function: String = #function,
        line: UInt = #line,
        tolerance: CGFloat = 0.01
    ) {
        assertSnapshot(
            matching: view,
            as: .image(precision: 1.0 - Float(tolerance)),
            named: device.indentifier,
            file: file,
            testName: function,
            line: line
        )
    }

    func makeWindow(for viewController: UIViewController, device: Device) -> UIWindow {
        let window = HostWindow(screen: device)
        UIView.setAnimationsEnabled(false)
        window.tintColor = .green
        window.rootViewController = viewController
        window.isHidden = false

        return window
    }

}

public enum Device {
    case iPhone6
    case iPhone6Plus
    case iPhoneX

    public static var all: [Device] {
        return [iPhone6, iPhone6Plus, iPhoneX]
    }

    public var size: CGSize {
        switch self {
        case .iPhone6:
            return CGSize(width: 375, height: 667)
        case .iPhone6Plus:
            return CGSize(width: 414, height: 736)
        case .iPhoneX:
            return CGSize(width: 375, height: 812)
        }
    }

    public var indentifier: String {
        switch self {
        case .iPhone6:
            return "iPhone6"
        case .iPhone6Plus:
            return "iPhone6Plus"
        case .iPhoneX:
            return "iPhoneX"
        }
    }

    public var traits: UITraitCollection {
        switch self {
        case .iPhone6:
            return .init(traitsFrom: [
                .init(displayScale: 2),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(userInterfaceIdiom: .phone)
                ]
            )
        case .iPhone6Plus:
            return .init(traitsFrom: [
                .init(displayScale: 3),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(userInterfaceIdiom: .phone)
                ]
            )
        case .iPhoneX:
            return .init(traitsFrom: [
                .init(displayScale: 3),
                .init(horizontalSizeClass: .compact),
                .init(verticalSizeClass: .regular),
                .init(userInterfaceIdiom: .phone)
                ]
            )
        }
    }
}

final class HostWindow: UIWindow {
    private let testScreen: Device

    override var traitCollection: UITraitCollection {
        return testScreen.traits
    }

    init(screen: Device) {
        self.testScreen = screen
        super.init(frame: .init(origin: .zero, size: screen.size))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
