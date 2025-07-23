import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct TestableFunctionMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        TestableMacro.self,
        TestableTypeMacro.self,
    ]
}
