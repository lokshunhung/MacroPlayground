//
//  ObservableObjectMacro.swift
//
//
//  Created by LS Hung on 29/06/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct NotPublishedMacro: SwiftSyntaxMacros.AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        return []
    }
}

public struct ObservableObjectMacro {}

extension ObservableObjectMacro: SwiftSyntaxMacros.ConformanceMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingConformancesOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [(TypeSyntax, GenericWhereClauseSyntax?)] {
        let inheritanceList: InheritedTypeListSyntax? =
            declaration.as(ClassDeclSyntax.self)?.inheritanceClause?.inheritedTypeCollection ??
            declaration.as(StructDeclSyntax.self)?.inheritanceClause?.inheritedTypeCollection
        for inheritance in inheritanceList ?? [] {
            let inheritedType = inheritance.typeName.as(SimpleTypeIdentifierSyntax.self)?
                .name.tokenKind
            if inheritedType == .identifier("ObservableObject") {
                context.addDiagnostics(from: Error.unnecessaryObservableObjectConformance, node: inheritance)
                return []
            }
        }
        return [
            (TypeSyntax(stringLiteral: "ObservableObject"), nil),
        ]
    }
}

extension ObservableObjectMacro: SwiftSyntaxMacros.MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let varDecl = member.as(VariableDeclSyntax.self) else {
            return []
        }

        // (@Published) Property wrapper can only apply to a single variable
        // so ignore decl if there are >1 bindings on the decl
        if varDecl.bindings.count > 1 {
            return []
        }

        for element in varDecl.attributes ?? [] {
            let attrName = element.as(AttributeSyntax.self)?
                .attributeName.as(SimpleTypeIdentifierSyntax.self)?
                .name.tokenKind
            if attrName == .identifier("NotPublished") {
                return []
            }
            if attrName == .identifier("Published") {
                context.addDiagnostics(from: Error.unnecessaryPublishedAttr, node: element)
            }
        }

        return [
            AttributeSyntax(attributeName: SimpleTypeIdentifierSyntax(
                name: .identifier("Published")
            )),
        ]
    }
}

extension ObservableObjectMacro {
    enum Error: Swift.Error, CustomStringConvertible {
        case unnecessaryObservableObjectConformance
        case unnecessaryPublishedAttr

        var description: String {
            switch self {
            case .unnecessaryObservableObjectConformance:
                "Unnecessary ObservableObject conformance"
            case .unnecessaryPublishedAttr:
                "Unnecessary @Published attribute"
            }
        }
    }
}
