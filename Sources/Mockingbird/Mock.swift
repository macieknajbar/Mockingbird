//
//  File.swift
//  
//
//  Created by Maciej Najbar on 15/02/2024.
//

import Foundation

public class Mock<T> {
    private let instance: T
    
    let uninitializedValue = NSObject()
    let uninitializedLambdaCall: (Any...) -> Void = { it in }
    
    var isStubbing = false
    var stubs: Dictionary<String, Any> = [:]
    var lambdaCalls: Dictionary<String, (Any...) -> Void> = [:]
    var counterCall: Dictionary<String, Int> = [:]
    var expectations: Dictionary<String, Expectations> = [:]
    var lastParams: Dictionary<String, Array<Any>> = [:]
    
    public var lastValues: Dictionary<String, Any> = [:]
    
    public init(instance anInstance: T) {
        instance = anInstance
    }
    
    public func on(block: (T) -> Any?) -> OngoingMock<T> {
        assert(!isStubbing, "Incomplete mock definition!")
        isStubbing = true
        
        let _ = block(instance)
        
        return OngoingMock(aMock: self)
    }
    
    public func withStubName<T2>(_ name: String, _ params: Any..., block: (T2?) -> T2) -> T2 {
        if isStubbing {
            cleanState()
            
            stubs[name] = uninitializedValue
            counterCall[name] = 0
            expectations[name] = Expectations(isMocking: true, times: -1, params: params, ignoredParams: [])
        } else {
            counterCall[name]! += 1
            lastParams[name] = params
            lambdaCalls[name]?(params)
        }
        
        let result = block(stubs[name] as? T2)
        lastValues[name] = result
        
        return block(result)
    }
    
    private func cleanState() {
        if var expectation = expectations.first(where: { it in it.value.isMocking }) {
            expectation.value.isMocking = false
            expectations[expectation.key] = expectation.value
        }
        if let entry = stubs.first(where: { it in it.value as? NSObject == uninitializedValue }) {
            stubs.removeValue(forKey: entry.key)
        }
    }
    
    public func verify() {
        for (key, value) in expectations {
            if value.times < 0 {
                continue
            }
            assert(
                value.times == counterCall[key],
                "\nMethod \"\(key)\" invoked \(counterCall[key]!) times, when expected \(value.times)."
            )
            if value.times == 0 {
                continue
            }
            
            for idx in 0 ..< value.params.count {
                if value.ignoredParams.contains(idx) {
                    continue
                }
                
                assert(
                    value.params[idx] as? NSObject == lastParams[key]![idx] as? NSObject,
                    """
                    Method \"\(key)\" got different params than expected.
                    Expected: \(String(describing: value.params))
                    Actual:   \(String(describing: lastParams[key]))
                    """
                )
            }
            
        }
    }
    
    struct Expectations {
        var isMocking: Bool
        var times: Int
        var params: Array<Any>
        var ignoredParams: Array<Int>
    }
}

public class OngoingMock<T> {
    private let mock: Mock<T>
    
    init(aMock: Mock<T>) {
        mock = aMock
    }
    
    @discardableResult
    public func willReturn(_ value: Any?) -> OngoingMock {
        mock.isStubbing = false
        
        guard let entry = mock.stubs.first(where: { it in it.value as? NSObject == mock.uninitializedValue }) else {
            print("You must stub only methods that return \"withStubName\"!")
            return self
        }
        mock.stubs[entry.key] = value
        
        return self
    }
    
    @discardableResult
    public func expectCall(times: Int = 1) -> OngoingMock {
        mock.isStubbing = false
        
        guard var entry = mock.expectations.first(where: {it in it.value.isMocking }) else {
            assert(false, "You must mock only methods that return \"withStubName\"!")
            return self
        }
        entry.value.times = times
        mock.expectations[entry.key] = entry.value
        
        return self
    }
    
    @discardableResult
    public func ignoringParams(at: Int...) -> OngoingMock {
        mock.isStubbing = false
        
        guard var entry = mock.expectations.first(where: {it in it.value.isMocking }) else {
            assert(false, "You must mock only methods that return \"withStubName\"!")
            return self
        }
        entry.value.ignoredParams = at
        mock.expectations[entry.key] = entry.value
        
        return self
    }
    
    @discardableResult
    public func call(_ block: @escaping (Any...) -> Void) -> OngoingMock {
        mock.isStubbing = false
        
        guard let (key, _) = mock.expectations.first(where: {it in it.value.isMocking }) else {
            assert(false, "You must mock only methods that return \"withStubName\"!")
            return self
        }
        mock.lambdaCalls[key] = block
        
        return self
    }
}
