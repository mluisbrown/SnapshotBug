# SnapshotBug
Test project to reproduce SnapshotTesting bug

This is just a sample project to reproduce a [bug](https://github.com/pointfreeco/swift-snapshot-testing/issues/163) I encountered with the [Swift Snapshot Testing library](https://github.com/pointfreeco/swift-snapshot-testing).

Only the test target is relevant. The app target is just there because it has to exist. It's unmodified from the Xcode single view app template.

Dependencies are ReactiveCocoa and SnapshotTesting, managed using CocoaPods. Just `pod install` and you should be all set.

When you run the tests (⌘U) they run fine but end in a crash in `UIApplicationMain`:

`Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)`

I have enabled Zombie Objects diagnostics for the test target and with that enabled you also get an error in the console similar to:

`*** -[CALayer setNeedsLayout]: message sent to deallocated instance 0x60000327d100`

You can make the bug happen earlier (before the tests end) if you uncomment the `autoreleasepool` block in [SnapshotBugTests.swift](https://github.com/mluisbrown/SnapshotBug/blob/master/SnapshotBugTests/SnapshotBugTests.swift#L11)

This will cause a slightly different Zombie error to appear in the console:

`*** -[UIWindowLayer isHidden]: message sent to deallocated instance 0x600000d4cd60`

This bug is somehow related with the async nature of the test and the fact that `SnapshotTesting` also uses `XCWaiter`. This kind of test works fine when using [ios-snapshot-test-case](https://github.com/uber/ios-snapshot-test-case] which is not async.

Somehow the combination of the two async code paths is probably causing the run loop to release objects which otherwise would not be released.
