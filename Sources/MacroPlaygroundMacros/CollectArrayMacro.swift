//
//  CollectArrayMacro.swift
//
//
//  Created by LS Hung on 25/07/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct CollectArrayMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {

        return "[]"
    }
}
