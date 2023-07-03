public enum Modifier {
    case `open`
    case `public`
    case `internal`
    case `fileprivate`
    case `private`

    case `attached`
    case `omitted`
}

@attached(peer, names: prefixed(`$`))
public macro Synchronized(modifier: Modifier? = nil) =
    #externalMacro(module: "MacroPlaygroundMacros", type: "SynchronizedMacro")
