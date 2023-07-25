//
//  CollectArray.swift
//
//
//  Created by LS Hung on 25/07/2023.
//

import Foundation

public struct CollectArrayTemplate: ExpressibleByStringInterpolation {
    public typealias StringLiteralType = String
    public init(stringLiteral: StringLiteralType) {}

    public typealias StringInterpolation = CollectArrayInterpolation
    public init(stringInterpolation: StringInterpolation) {}
}

public struct CollectArrayInterpolation: StringInterpolationProtocol {
    public typealias StringLiteralType = String

    public init(literalCapacity: Int, interpolationCount: Int) {}

    public func appendLiteral(_ literal: StringLiteralType) {}

    public var appendInterpolation: DynamicVoidCallable { .init() }

    @_disfavoredOverload
    public func appendInterpolation(_: Never) {}
}

@dynamicCallable
public struct DynamicVoidCallable {
    public func dynamicallyCall(withArguments args: [Any]) {}

    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any>) {}
}

@freestanding(expression)
public macro CollectArray<T>(_ template: CollectArrayTemplate) -> Array<T> =
    #externalMacro(module: "MacroPlaygroundMacros", type: "CollectArrayMacro")

let a = CollectArrayTemplate("""
\(1) \(b: 2)
""")
