@attached(member, names: named(init))
public macro FatalCoderInit(message: String? = nil) =
    #externalMacro(module: "MacroPlaygroundMacros", type: "FatalCoderInitMacro")
