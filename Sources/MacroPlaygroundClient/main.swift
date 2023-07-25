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

let foo: String = "init(coder:) has not been implemented"
@FatalCoderInit(message: foo)
class C: NSView {
    override init(frame frameRect: NSRect) {
        super.init(frame: .zero)
    }
}

struct Obj {
    private let lock: Lock

    @Synchronized
    func foo(_ a: Int, b bb: Bool, c: Character) {
        print("T")
    }

    @Synchronized(modifier: .attached)
    fileprivate func bar(_ a: Int, b bb: Bool, c: Character) {
        print("T")
    }

    @Synchronized(modifier: .public)
    fileprivate func boom(_ a: Int, b bb: Bool, c: Character) {
        print("T")
    }
}

//let _ = CollectArrayTemplate("""
//    a    | b       | c
//    \(1) | \(b: 2)
//""")

_ = #CollectArray<(Int, b: Int)>("""
    a    | b
    \(1) | \(b: 2)
    """)
