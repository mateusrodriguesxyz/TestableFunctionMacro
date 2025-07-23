import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(TestableFunctionMacroMacros)
import TestableFunctionMacroMacros

let testMacros: [String: Macro.Type] = [
    "Testable": TestableMacro.self,
]
#endif

final class TestableFunctionMacroTests: XCTestCase {
    
    func testTestable() throws {
        #if canImport(TestableFunctionMacroMacros)
        assertMacroExpansion(
            """
            class Model {
                @Testable
                func f1() {
                    print(#function)
                }
            
                @Testable
                public func f2(_ a: Int) {
                    print(#function)
                }
            
                @Testable
                public func f3(a: Int, b: Int) {
                    print(#function)
                }
            }
            """,
            expandedSource: """
            class Model {
                func f1() {
                    self.`f1()`.append(())
                    print(#function)
                }

                var `f1()` = FunctionCallRegistrar<Void, Void>()
                public func f2(_ a: Int) {
                    self.`f2(_:)`.append(a)
                    print(#function)
                }
            
                var `f2(_:)` = FunctionCallRegistrar<Int, Int>()
                public func f3(a: Int, b: Int) {
                    self.`f3(a:b:)`.append(a, b)
                    print(#function)
                }
            
                var `f3(a:b:)` = FunctionCallRegistrar<(a: Int, b: Int), Int, Int>()
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}
