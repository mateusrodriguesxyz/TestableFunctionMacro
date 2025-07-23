import XCTest
import Testing
@testable import TestableFunctionMacroClient
import TestableFunctionMacro

@Testable
class MockModel {
    
    public init() {}

    public func f1() {
        print(#function)
    }

    public func f2(_ a: Int) {
        print(#function)
    }

    public func f3(a: Int, b: Int) {
        print(#function)
    }
    
    public func f4() {
        print(#function)
    }
    
    public func f5(a: Int, b: Int) {
        print(#function)
    }
    
    public func f5(a: Int, b: String) {
        print(#function)
    }
    
}

struct ModelTests {
    
    @MainActor
    @Test func modelFunctions() {
        let model = MockModel()
        
        model.f1()
        model.f2(0)
        model.f3(a: 1, b: 2)
        model.f5(a: 1, b: 2)
        
        #expect(model.`f1()`.hasBeenCalled)
        #expect(model.`f2(_:)`.hasBeenCalled(2) == false)
        #expect(model.`f3(a:b:)`.hasBeenCalled(1...2))
        #expect(model.`f4()`.hasBeenCalled == false)
        #expect(model.`f5(a:Int,b:Int)`.hasBeenCalled)
        #expect(model.`f5(a:Int,b:String)`.hasBeenCalled == false)
        
        #expect(model.`f3(a:b:)`.hasBeenCalled(with: 1, 2))
        #expect(model.`f3(a:b:)`.hasBeenCalled(with: 1, 3) == false)
        #expect(model.`f3(a:b:)`.hasBeenCalled(with: .value(1), .any))
        #expect(model.`f3(a:b:)`.hasBeenCalled(with: .value(1), .any(2, 3)))
        
        #expect(model.`f2(_:)`[0].input == 0)
        #expect(model.`f3(a:b:)`[0].input.a == 1)
        #expect(model.`f3(a:b:)`[0].input.b == 2)
        
        
    }
    
}
