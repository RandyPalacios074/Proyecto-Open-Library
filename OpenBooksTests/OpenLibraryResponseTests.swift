import Foundation
import XCTest
@testable import OpenBooks

final class OpenLibraryResponseTests: XCTestCase {
    func testDecodesRealSearchFields() throws {
        let data = Data("""
        {"docs":[{"key":"/works/OL100W","title":"El hobbit","author_name":["J. R. R. Tolkien"],"first_publish_year":1937,"cover_i":25,"subject":["Fantasía","Aventura"]}]}
        """.utf8)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
        let book = try XCTUnwrap(response.docs.first?.asBook())

        XCTAssertEqual(book.id, "/works/OL100W")
        XCTAssertEqual(book.title, "El hobbit")
        XCTAssertEqual(book.author, "J. R. R. Tolkien")
        XCTAssertEqual(book.year, "1937")
        XCTAssertEqual(book.coverID, 25)
        XCTAssertEqual(book.themes, ["Fantasía", "Aventura"])
    }

    func testDecodesOptionalFieldsMissing() throws {
        let data = Data("""
        {"docs":[{"key":"OL200W","title":"Libro sin portada"}]}
        """.utf8)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
        let book = try XCTUnwrap(response.docs.first?.asBook())

        XCTAssertEqual(book.id, "/works/OL200W")
        XCTAssertEqual(book.author, "Autor desconocido")
        XCTAssertNil(book.year)
        XCTAssertNil(book.coverID)
        XCTAssertFalse(book.hasCover)
    }

    func testDecodesEmptyResponse() throws {
        let data = Data(#"{"docs":[]}"#.utf8)
        let response = try JSONDecoder().decode(OpenLibrarySearchResponse.self, from: data)
        XCTAssertTrue(response.docs.isEmpty)
    }
}
