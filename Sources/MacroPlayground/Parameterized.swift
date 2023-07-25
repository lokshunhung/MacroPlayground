//
//  Parameterized.swift
//
//
//  Created by LS Hung on 25/07/2023.
//

import Foundation

@attached(member, names: named(input), named(defaultTestSuite), named(addNewTest))
public macro Parameterized<T>(_ inputs: T...) =
    #externalMacro(module: "MacroPlaygroundMacros", type: "ParameterizedMacro")
