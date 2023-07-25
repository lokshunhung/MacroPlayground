//
//  ParameterizedMacro.swift
//
//
//  Created by LS Hung on 25/07/2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ParameterizedMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            throw Error.onlyApplicableToXCTestClass
        }
        guard classDecl.modifiers?.contains(where: { $0.name.tokenKind == .keyword(.final) }) == true else {
            throw Error.onlyApplicableToXCTestClass
        }
        guard classDecl.identifier.text.hasSuffix("Tests") else {
            throw Error.onlyApplicableToXCTestClass
        }

        guard let attributeArguments = node.argument?.as(TupleExprElementListSyntax.self) else {
            throw Error.missingAttributeArguments
        }
        guard let attributeGenericArguments = node.attributeName.as(SimpleTypeIdentifierSyntax.self)?.genericArgumentClause?.arguments,
              let attributeGenericArgument = attributeGenericArguments.first,
              attributeGenericArguments.count == 1 else {
            throw Error.missingAttributeGenericArgument
        }

        let inputDecl: DeclSyntax =
            "var input: \(attributeGenericArgument)!"

        let defaultTestSuiteDecl: VariableDeclSyntax = try .init(
            "override static var defaultTestSuite: XCTestSuite") {
                "let testSuite = XCTestSuite(name: NSStringFromClass(self))"
                for argument in attributeArguments {
                    let arg = argument
                        .with(\.leadingTrivia, [])
                        .with(\.trailingTrivia, [])
                    "addNewTest(\(arg), to: testSuite)"
                }
                "return testSuite"
            }

        let addNewTestDecl: FunctionDeclSyntax = try .init(
            "private static func addNewTest(_ input: Input, to testSuite: XCTestSuite)") {
                try ForInStmtSyntax(
                    "for invocation in self.testInvocations") {
                        "let testCase = \(classDecl.identifier)(invocation: invocation)"
                        "testCase.input = input"
                        "testSuite.addTest(testCase)"
                    }
            }

        return [
            inputDecl,
            .init(defaultTestSuiteDecl),
            .init(addNewTestDecl),
        ]
    }

    enum Error: Swift.Error {
        case onlyApplicableToXCTestClass
        case missingAttributeArguments
        case missingAttributeGenericArgument
    }
}
