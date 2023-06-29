//
//  ObservableObject.swift
//
//
//  Created by LS Hung on 29/06/2023.
//

@attached(conformance)
@attached(memberAttribute)
public macro ObservableObject() =
    #externalMacro(module: "MacroPlaygroundMacros", type: "ObservableObjectMacro")

@attached(accessor)
public macro NotPublished() =
    #externalMacro(module: "MacroPlaygroundMacros", type: "NotPublishedMacro")
