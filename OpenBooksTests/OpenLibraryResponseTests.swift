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

    func testWorkDescriptionAsText() throws {
        let data = Data(#"{"description":"Historia de una aventura.","subjects":["Fantasía"]}"#.utf8)
        let details = try JSONDecoder().decode(OpenLibraryWorkResponse.self, from: data).asDetails()
        XCTAssertEqual(details.description, "Historia de una aventura.")
        XCTAssertEqual(details.themes, ["Fantasía"])
        XCTAssertNil(details.coverID)
    }

    func testWorkDescriptionAsObjectAndCover() throws {
        let data = Data("""
        {"description":{"type":"/type/text","value":"Una novela clásica."},
         "subjects":["Aventura","Ficción"],"covers":[-1,248]}
        """.utf8)
        let details = try JSONDecoder().decode(OpenLibraryWorkResponse.self, from: data).asDetails()
        XCTAssertEqual(details.description, "Una novela clásica.")
        XCTAssertEqual(details.coverID, 248)
        XCTAssertEqual(details.themes, ["Aventura", "Ficción"])
    }

    func testWorkWithoutDescriptionDoesNotInventOne() throws {
        let data = Data(#"{"subjects":[]}"#.utf8)
        let details = try JSONDecoder().decode(OpenLibraryWorkResponse.self, from: data).asDetails()
        XCTAssertNil(details.description)
        XCTAssertTrue(details.themes.isEmpty)
    }

    func testBookCanBeCachedAsJSON() throws {
        let original = Book(title: "Un libro", author: "Autora", year: nil,
                            hasCover: true, isSaved: false,
                            id: "/works/OL123W", coverID: 123)
        let data = try JSONEncoder().encode([original])
        let recovered = try JSONDecoder().decode([Book].self, from: data)
        XCTAssertEqual(recovered.first?.id, original.id)
        XCTAssertEqual(recovered.first?.coverID, 123)
        XCTAssertNil(recovered.first?.year)
    }

}
