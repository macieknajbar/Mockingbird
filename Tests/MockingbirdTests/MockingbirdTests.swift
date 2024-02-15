import XCTest
@testable import Mockingbird

final class MockingbirdTests: XCTestCase {
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
    
    func testTimestampProvider() {
        let expected = 44.0
        let timestampProvider = TimestampProviderMock { mock in
            mock.on { $0.get() }.willReturn(44.0)
            return
        }
    
        let actual = timestampProvider.get()
    
        XCTAssertEqual(expected, actual)
    }
    
    func testPrintDocument() {
        let document = "Very important document"
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: document) }.expectCall()
            return
        }
    
        Company(printer: printer)
            .printDocument(document: document)
    
        printer.mock.verify()
    }
    
    func testPrintDocument2() {
        let document = "Very important document"
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: "") }.ignoringParams(at: 0).expectCall()
            return
        }
    
        Company(printer: printer)
            .printDocument(document: document)
    
        printer.mock.verify()
    }
    
    func testPrintDocumentWithRealTimestamp() {
        let document = "Very important document"
        let timestampProvider = RealTimestampProvider()
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: document, timestamp: 44) }.ignoringParams(at: 1).expectCall()
            return
        }
    
        Company(
            printer: printer,
            timestampProvider: timestampProvider
        ).printDocument(document: document)
    
        printer.mock.verify()
    }
    
    func testPrintAnyDocumentWithRealTimestamp() {
        let document = "Very important document"
        let timestampProvider = RealTimestampProvider()
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: "", timestamp: 44)}.ignoringParams(at: 0, 1).expectCall()
            return
        }
    
        Company(
            printer: printer,
            timestampProvider: timestampProvider
        ).printDocument(document: document)
    
        printer.mock.verify()
    }
    
    func testPrintDocumentWithTimestamp() {
        let document = "Very important document"
        let timestampProvider = TimestampProviderMock { mock in
            mock.on { $0.get() }.willReturn(44.0)
            return
        }
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: document, timestamp: 44)}.expectCall()
            return
        }
    
        Company(
            printer: printer,
            timestampProvider: timestampProvider
        ).printDocument(document: document)
    
        printer.mock.verify()
    }
    
    func testPrintDocumentWithSignature() {
        let document = "Very important document"
        let employee = Employee(name: "Maciej Najbar")
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: document, signature: SignatureMock()) }.expectCall()
            return
        }
    
        Company(printer: printer)
            .printDocument(document: document, employee: employee)
    
        printer.mock.verify()
    }
    
    func testRepository() {
        let id = "id"
        let expected = "expected value"
        let repository = RepositoryMock { mock in
            mock.on { $0.save(id: id, record: expected) }.expectCall()
            mock.on { $0.read(id: id)! }.willReturn(expected).expectCall()
        }
    
        repository.save(id: id, record: expected)
        let actual = repository.read(id: id)
    
        assert(expected == actual)
        repository.mock.verify()
    }
    
    func testSuccess() {
        let expected = "Important response"
        let getItem = GetItemMock { mock in
            mock.on { $0.getItem(onError: {}, onSuccess: { response in }) }
                .call(((String) -> Void).self, paramAt: 1) { $0(expected) }
            return
        }
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: expected )}.expectCall()
            return
        }
    
        let sut: (GetItem, Printer) -> Void = { getItem, printer in
            getItem.getItem(onError: {}) { printer.print(document: $0) }
        }
        sut(getItem, printer)
    
        printer.mock.verify()
    }
    
    func testFailure() {
        let expected = "Important response"
        let getItem = GetItemMock { mock in
            mock.on { $0.getItem(onError: {}, onSuccess: { response in }) }
                .call((() -> Void).self, paramAt: 0) { $0() }
            return
        }
        let printer = PrinterMock { mock in
            mock.on { $0.print(document: expected )}.expectCall(times: 0)
            return
        }
    
        let sut: (GetItem, Printer) -> Void = { getItem, printer in
            getItem.getItem(onError: {}) { printer.print(document: $0) }
        }
        sut(getItem, printer)
    
        printer.mock.verify()
    }
    
    func testReturnNil() {
        let timestampProvider = TimestampProviderMock { mock in
            mock.on { $0.get() }.willReturn(nil).expectCall()
            return
        }
    
        let _ = timestampProvider.get()
    
        timestampProvider.mock.verify()
    }
}

protocol TimestampProvider {
    func get() -> Double?
}

class TimestampProviderMock : TimestampProvider {
    var mock: Mock<TimestampProvider>!
    
    init(mocking: (Mock<TimestampProvider>) -> Void) {
        mock = Mock(instance: self)
        mocking(mock)
    }
    
    func get() -> Double? {
        mock.withStubName("get") { $0 as? Double }
    }
}

class RealTimestampProvider : TimestampProvider {
    func get() -> Double? {
        return Date().timeIntervalSince1970
    }
}

protocol GetItem {
    func getItem(onError: @escaping () -> Void, onSuccess: @escaping (String) -> Void)
}

class GetItemMock : GetItem {
    var mock: Mock<GetItem>!
    
    init(mocking: (Mock<GetItem>) -> Void) {
        mock = Mock(instance: self)
        mocking(mock)
    }
    
    func getItem(onError: @escaping () -> Void, onSuccess: @escaping (String) -> Void) {
        mock.withStubName("getItem", onError, onSuccess) { $0 }
    }
}

public protocol Printer {
    func print(document: String)
    func print(document: String, timestamp: Double)
    func print(document: String, signature: Signature)
}

public class PrinterMock : Printer {
    public var mock: Mock<Printer>!
    
    public init(stubbing: (Mock<Printer>) -> Void) {
        mock = Mock(instance: self)
        stubbing(mock)
    }
    
    public func print(document: String) {
        mock.withStubName("print", document) { it in }
    }
    
    public func print(document: String, timestamp: Double) {
        mock.withStubName("printTimestamp", document, timestamp) { it in }
    }
    
    public func print(document: String, signature: Signature) {
        mock.withStubName("print(String, Signature)", document, signature) { it in }
    }
}

class Company {
    let printer: Printer
    let timestampProvider: TimestampProvider?
    
    init(printer: Printer, timestampProvider: TimestampProvider? = nil) {
        self.printer = printer
        self.timestampProvider = timestampProvider
    }
    
    func printDocument(document: String) {
        if let tp = timestampProvider {
            printer.print(document: document, timestamp: tp.get() ?? 0)
        } else {
            printer.print(document: document)
        }
    }
    
    public func printDocument(document: String, employee: Employee) {
        printer.print(document: document, signature: Signature(employee: employee))
    }
}

public class Signature : Equatable {
    
    public static func == (lhs: Signature, rhs: Signature) -> Bool {
        return lhs.employee.name == rhs.employee.name
    }
    
    public let employee: Employee
    
    public init(employee: Employee) {
        self.employee = employee
    }
    
    public func get() -> String {
        return employee.name + "_hash_123"
    }
}

public class Employee {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}

public class SignatureMock : Signature {
    public var mock: Mock<Signature>!
    
    public init(mocking: (Mock<Signature>) -> Void = { mock in }) {
        super.init(employee: EmployeeMock())
        mock = Mock(instance: self)
        mocking(mock)
    }
}

public class EmployeeMock : Employee {
    public var mock: Mock<Employee>!
    
    public init(mocking: (Mock<Employee>) -> Void = { mock in }) {
        super.init(name: UUID().uuidString)
        mock = Mock(instance: self)
        mocking(mock)
    }
}

public protocol Repository {
    associatedtype Item
    
    func save(id: String, record: Item)
    func read(id: String) -> Item?
}

public class SimpleRepository<T> : Repository {
    public typealias Item = T
    
    public func save(id: String, record: T) { }
    public func read(id: String) -> T? { return nil }
}

public class RepositoryMock : SimpleRepository<String> {
    public var mock: Mock<SimpleRepository<String>>!
    
    public init(mocking: (Mock<SimpleRepository<String>>) -> Void = { mock in }) {
        super.init()
        mock = Mock(instance: self)
        mocking(mock)
    }
    
    public override func save(id: String, record: String) {
        mock.withStubName("save(String, String)", id, record) { mock in }
    }
    
    public override func read(id: String) -> String {
        return mock.withStubName("read(String)", id) { $0 ?? "" }
    }
}
