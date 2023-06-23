import MacroPlayground
import Cocoa

//@FatalCoderInit
open class A: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@FatalCoderInit
open class B: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
    }
}
