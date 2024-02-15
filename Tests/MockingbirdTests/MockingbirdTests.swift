import XCTest
@testable import Mockingbird

final class MockingbirdTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}

//import UIKit
//
//func testTimestampProvider() {
//    let expected = 44.0
//    let timestampProvider = TimestampProviderMock { mock in
//        mock.on { $0.get() }.willReturn(44.0)
//        return
//    }
//    
//    let actual = timestampProvider.get()
//    
//    assert(
//        expected == actual,
//        "Assertion failed:\nExpected: \(expected)\nActual: \(actual)"
//    )
//}
//
//testTimestampProvider()
//
//func testPrintDocument() {
//    let document = "Very important document"
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: document) }.expectCall()
//        return
//    }
//    
//    Company(printer: printer)
//        .printDocument(document: document)
//    
//    printer.mock.verify()
//}
//
//testPrintDocument()
//
//func testPrintDocument2() {
//    let document = "Very important document"
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: "") }.ignoringParams(at: 0).expectCall()
//        return
//    }
//    
//    Company(printer: printer)
//        .printDocument(document: document)
//    
//    printer.mock.verify()
//}
//
//testPrintDocument2()
//
//func testPrintDocumentWithRealTimestamp() {
//    let document = "Very important document"
//    let timestampProvider = RealTimestampProvider()
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: document, timestamp: 44)}.ignoringParams(at: 1).expectCall()
//        return
//    }
//    
//    Company(
//        printer: printer,
//        timestampProvider: timestampProvider
//    ).printDocument(document: document)
//    
//    printer.mock.verify()
//}
//
//testPrintDocumentWithRealTimestamp()
//
//func testPrintAnyDocumentWithRealTimestamp() {
//    let document = "Very important document"
//    let timestampProvider = RealTimestampProvider()
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: "", timestamp: 44)}.ignoringParams(at: 0, 1).expectCall()
//        return
//    }
//    
//    Company(
//        printer: printer,
//        timestampProvider: timestampProvider
//    ).printDocument(document: document)
//    
//    printer.mock.verify()
//}
//
//testPrintAnyDocumentWithRealTimestamp()
//
//func testPrintDocumentWithTimestamp() {
//    let document = "Very important document"
//    let timestampProvider = TimestampProviderMock { mock in
//        mock.on { $0.get() }.willReturn(44.0)
//        return
//    }
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: document, timestamp: 44)}.expectCall()
//        return
//    }
//    
//    Company(
//        printer: printer,
//        timestampProvider: timestampProvider
//    ).printDocument(document: document)
//    
//    printer.mock.verify()
//}
//
//testPrintDocumentWithTimestamp()
//
//func testPrintDocumentWithSignature() {
//    let document = "Very important document"
//    let employee = Employee(name: "Maciej Najbar")
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: document, signature: SignatureMock()) }.expectCall()
//        return
//    }
//    
//    Company(printer: printer)
//        .printDocument(document: document, employee: employee)
//    
//    printer.mock.verify()
//}
//
//testPrintDocumentWithSignature()
//
//func testRepository() {
//    let id = "id"
//    let expected = "expected value"
//    let repository = RepositoryMock { mock in
//        mock.on { $0.save(id: id, record: expected) }.expectCall()
//        mock.on { $0.read(id: id)! }.willReturn(expected).expectCall()
//    }
//    
//    repository.save(id: id, record: expected)
//    let actual = repository.read(id: id)
//    
//    assert(expected == actual)
//    repository.mock.verify()
//}
//
//testRepository()
//
//func testSuccess() {
//    let expected = "Important response"
//    let getItem = GetItemMock { mock in
//        mock.on { $0.getItem(onError: {}, onSuccess: { response in }) }
//            .call { params in (params[1] as! (String) -> Void)(expected) }
//        return
//    }
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: expected )}.expectCall()
//        return
//    }
//    
//    let sut: (GetItem, Printer) -> Void = { getItem, printer in
//        getItem.getItem(onError: {}) { printer.print(document: $0) }
//    }
//    sut(getItem, printer)
//    
//    printer.mock.verify()
//}
//
//testSuccess()
//
//func testFailure() {
//    let expected = "Important response"
//    let getItem = GetItemMock { mock in
//        mock.on { $0.getItem(onError: {}, onSuccess: { response in }) }
//            .call { params in (params[0] as! () -> Void)() }
//        return
//    }
//    let printer = PrinterMock { mock in
//        mock.on { $0.print(document: expected )}.expectCall(times: 0)
//        return
//    }
//    
//    let sut: (GetItem, Printer) -> Void = { getItem, printer in
//        getItem.getItem(onError: {}) { printer.print(document: $0) }
//    }
//    sut(getItem, printer)
//    
//    printer.mock.verify()
//}
//
//testFailure()
//
//func testReturnNil() {
//    let timestampProvider = TimestampProviderMock { mock in
//        mock.on { $0.get() }.willReturn(nil).expectCall()
//        return
//    }
//    
//    timestampProvider.get()
//    
//    timestampProvider.mock.verify()
//}
//
//testReturnNil()
