@attached(member, names: named(init))
public macro FatalCoderInit() =
    #externalMacro(module: "MacroPlaygroundMacros", type: "FatalCoderInit")
