import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension FunctionDeclSyntax {
    
    var symbolName: String {
        let name = name.text
        let signature = signature.parameterClause.parameters.map { parameter in
            parameter.firstName.text + ":"
        }
        return "\(name)(\(signature.joined()))"
    }
    
    var symbolNameExtended: String {
        let name = name.text
        let signature = signature.parameterClause.parameters.map { parameter in
            parameter.firstName.text + ":\(parameter.type.trimmedDescription)"
        }
        return "\(name)(\(signature.joined(separator: ",")))"
    }
    
}

public struct TestableTypeMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard let member = member.as(FunctionDeclSyntax.self) else {
            return []
        }
        
        let members = declaration.memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        let peers = members.filter({ $0.symbolName == member.symbolName })

        if peers.count > 1 {
            return ["@TestableFunction(\"\(raw: member.symbolNameExtended)\")"]
        } else {
            return ["@TestableFunction"]
        }

    }
}


public struct TestableMacro: PeerMacro, BodyMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }
        
        let labeledInputType = switch declaration.signature.parameterClause.parameters.count {
            case 0:
                "Void"
            case 1:
                declaration.signature.parameterClause.parameters.first!.type.trimmedDescription
            default:
                "(" +
                declaration.signature.parameterClause.parameters
                    .map {
                        ($0.secondName?.text ?? $0.firstName.text) + ": " + $0.type.trimmedDescription
                    }
                    .joined(separator: ", ")
                + ")"
                
        }
//        return ["var `\(raw: declaration.symbolName)` = FunctionCallRegistrar<\(raw: inputType)>()"]
        
        let inputType =
            if declaration.signature.parameterClause.parameters.isEmpty {
                "Void"
            } else {
                declaration.signature.parameterClause.parameters.map(\.type.trimmedDescription).joined(separator: ", ")
            }
        
        let name = node.arguments?.as(LabeledExprListSyntax.self)?.first?
            .expression.as(StringLiteralExprSyntax.self)?.segments.trimmedDescription ?? declaration.symbolName
        
        return [
            """
            #if DEBUG
            var `\(raw: name)` = FunctionCallRegistrar<\(raw: labeledInputType), \(raw: inputType)>()
            #endif
            """
        ]
        
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        guard let declaration = declaration.as(FunctionDeclSyntax.self) else {
            return []
        }
        guard let body = declaration.body?.statements.map(\.self) else {
            return []
        }
        let input = if declaration.signature.parameterClause.parameters.isEmpty {
            "()"
        } else {
            declaration.signature.parameterClause.parameters.map({ $0.secondName?.text ?? $0.firstName.text }).joined(separator: ", ")
        }
        
        let name = node.arguments?.as(LabeledExprListSyntax.self)?.first?
            .expression.as(StringLiteralExprSyntax.self)?.segments.trimmedDescription ?? declaration.symbolName
        
        return [
            """
            #if DEBUG
            self.`\(raw: name)`.append(\(raw: input))
            #endif
            """
        ] + body

    }
    
}



