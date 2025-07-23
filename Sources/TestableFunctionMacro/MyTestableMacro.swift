@attached(peer, names: arbitrary)
@attached(body)
public macro TestableFunction(_ name: String? = nil) = #externalMacro(
    module: "TestableFunctionMacroMacros",
    type: "TestableMacro"
)

@attached(memberAttribute)
public macro Testable(_ name: String? = nil) = #externalMacro(
    module: "TestableFunctionMacroMacros",
    type: "TestableTypeMacro"
)

//public final class FunctionCallRegistrar<Input> {
//    public var calls: [Input] = []
//    public init() { }
//    public var hasBeenCalled: Bool {
//        calls.count > 0
//    }
//    public func hasBeenCalled(_ count: Int) -> Bool {
//        calls.count == count
//    }
//    public func hasBeenCalled(_ range: ClosedRange<Int>) -> Bool {
//        range.contains(calls.count)
//    }
//}

public enum FunctionInputValue<T> {
    case value(T)
    case any([T])
    public static var any: Self { .any([]) }
    public static func any(_ values: T...) -> Self { .any(values) }
}

extension FunctionInputValue: ExpressibleByIntegerLiteral where T == Int {
    public init(integerLiteral value: T) {
        self = .value(value)
    }
}

public final class FunctionCallRegistrar<LabeledInput, each T> {
    
    public struct FunctionCall {
        let values: (repeat each T)
        init(_ values: repeat each T) {
            self.values = (repeat each values)
        }
        public var input: LabeledInput {
            (repeat each values) as! LabeledInput
        }
        public func matches(_ values: repeat each T) -> Bool where repeat each T: Equatable {
            for isEqual in repeat each self.values == each values {
                guard isEqual else { return false }
            }
            return true
        }
        
        public func matches(_ values: repeat FunctionInputValue<each T>) -> Bool where repeat each T: Equatable {
            for (lhs, rhs) in repeat (each self.values, each values) {
                let isEqual = switch rhs {
                case .value(let value):
                    lhs == value
                case .any(let values):
                    if values.isEmpty {
                        true
                    } else {
                        values.contains(lhs)
                    }
                }
                guard isEqual else { return false }
            }
            return true
        }
        
    }
    
    private var calls: [FunctionCall] = []
    
    public init() { }
    
    public func append(_ input: repeat each T) {
        calls.append(.init(repeat each input))
    }
    
    public subscript(index: Int) -> FunctionCall {
        self.calls[index]
    }
    
    public var hasBeenCalled: Bool {
        calls.count > 0
    }
    
    public func hasBeenCalled(_ count: Int) -> Bool {
        calls.count == count
    }
    public func hasBeenCalled(_ range: ClosedRange<Int>) -> Bool {
        range.contains(calls.count)
    }
    
    public func hasBeenCalled(with values: repeat each T) -> Bool where repeat each T: Equatable {
        calls.contains {
            $0.matches(repeat each values)
        }
    }

    public func hasBeenCalled(_ count: Int, with values: repeat each T) -> Bool where repeat each T: Equatable {
        calls.filter {
            $0.matches(repeat each values)
        }
        .count == count
    }
    
    public func hasBeenCalled(_ range: ClosedRange<Int>, with values: repeat each T) -> Bool where repeat each T: Equatable {
        range.contains(
            calls.filter {
                $0.matches(repeat each values)
            }
            .count
        )
    }
    
    public func hasBeenCalled(with values: repeat FunctionInputValue<each T>) -> Bool where repeat each T: Equatable {
        calls.contains {
            $0.matches(repeat each values)
        }
    }
    
}
