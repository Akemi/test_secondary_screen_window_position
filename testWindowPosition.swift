import Cocoa

let debug: Bool           = false
let screenNumberTest: Int = 2
let testCases: [String]   = ["width", "height"]
var titleBarHeight: Int   = Int(NSWindow.frameRect(forContentRect: CGRect.zero, styleMask: .titled).size.height+1)


print("You have \(NSScreen.screens.count) screen(s):")

for (num, screen) in NSScreen.screens.enumerated() {
    print("Screen \(num+1): \(screen.frame)")
}

print("----------------------------------------------------")

if NSScreen.screens.count < screenNumberTest {
    print("\u{001B}[0;31mYou need at least \(screenNumberTest) screens\u{001B}[0;0m")
    exit(0)
}

let screenToTest = NSScreen.screens[screenNumberTest-1]
var mainFrame = NSScreen.screens[0].frame
var testFrame = screenToTest.frame
mainFrame.origin.x = 0
mainFrame.origin.y = 0
testFrame.origin.x = 0
testFrame.origin.y = 0

if NSContainsRect(mainFrame, testFrame) {
    print("\u{001B}[0;31mScreen 1 and \(screenNumberTest) need two different virtual resolutions.")
    print("Either width or height of screen \(screenNumberTest) needs to be greater than the one of screen 1.\u{001B}[0;0m")
    exit(0)
}

print("Trying window positions on screen \(screenNumberTest) with a resolution of \(Int(testFrame.size.width))x\(Int(testFrame.size.height))")

for dim in testCases {
    let positionText = dim == "width" ? "x" : "y"
    let end = dim == "width" ? Int(testFrame.size.width) : Int(testFrame.size.height)
    var fuckUpCount: Int = 0
    var lastFuckUp: Int  = 0

    print("Testing screen's \(positionText) position from 0 to \(end-1)")

    for index in 0...end-1 {
        let rect = dim == "width" ? NSRect(x: index, y: 0, width: 1, height: 1)
                                  : NSRect(x: 0, y: index, width: 1, height: 1)
        let window = NSWindow(contentRect: rect,
                            styleMask: [.titled, .fullSizeContentView],
                              backing: .buffered,
                                defer: false,
                               screen: screenToTest)
        var actual = window.frame.origin
        actual.x -= screenToTest.frame.origin.x
        actual.y -= screenToTest.frame.origin.y

        let testPosition =   dim == "width" ? Int(rect.origin.x) : Int(rect.origin.y)
        let actualPosition = dim == "width" ? Int(actual.x) : Int(actual.y)

        if debug {
            let pass = testPosition == actualPosition ? "[0;32m" : "[0;31m"
            print("\u{001B}\(pass)\(positionText) position expected: \(testPosition) actual: \(actualPosition)")
        } else {
            if testPosition != actualPosition {

                if lastFuckUp != actualPosition-1 {
                    if fuckUpCount < 1 {
                        print("\u{001B}[0;32m\(positionText) position from 0 to \(testPosition-1) were okay")
                        if dim == "height" {
                            print("Keep in mind your title bar is \(titleBarHeight)pt high and the actual usable height of screen 1 " +
                                  "is 0-\(Int(mainFrame.size.height)-titleBarHeight-1)pt of the \(Int(mainFrame.size.height)) points.")
                        }

                    }
                    print("\u{001B}[0;31m\(positionText) position jump: \(fuckUpCount+1)")
                    print("\u{001B}[0;31m\(positionText) position expected: \(testPosition) actual: \(actualPosition)")
                    fuckUpCount += 1
                }

                lastFuckUp = actualPosition
            }
        }
    }
    print("\u{001B}[0;0m")
}
