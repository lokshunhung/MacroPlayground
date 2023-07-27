//
//  ParameterizedTest.swift
//
//
//  Created by LS Hung on 26/07/2023.
//

import Foundation

//public struct _ParameterizedTestTemplate: ExpressibleByStringInterpolation {
//    public typealias StringLiteralType = String
//    public init(stringLiteral value: StringLiteralType) {}
//
//    public typealias StringInterpolation = _ParameterizedTestInterpolation
//    public init(stringInterpolation: StringInterpolation) {}
//}
//
//public struct _ParameterizedTestInterpolation: StringInterpolationProtocol {
//    public init(literalCapacity: Int, interpolationCount: Int) {}
//
//    public typealias StringLiteralType = String
//    public func appendLiteral(_ literal: StringLiteralType) {}
//
//    public func appendInterpolation(_: Any?) {}
//}
//
//@attached(peer, names: arbitrary)
//public macro ParameterizedTest(_ template: _ParameterizedTestTemplate) =
//    #externalMacro(module: "MacroPlaygroundMacros", type: "ParameterizedTestMacro")


//@attached(peer, names: arbitrary)
//public macro ParameterizedTest(_ values: [Any]) =
//    #externalMacro(module: "MacroPlaygroundMacros", type: "ParameterizedTestMacro")

@attached(peer, names: arbitrary)
public macro ParameterizedTest<T>(_ values: [T]) =
    #externalMacro(module: "MacroPlaygroundMacros", type: "ParameterizedTestMacro")

@attached(peer, names: arbitrary)
public macro ParameterizedTest<T>(_ values: [String: T]) =
    #externalMacro(module: "MacroPlaygroundMacros", type: "ParameterizedTestMacro")
