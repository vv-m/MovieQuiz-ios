import XCTest
@testable import MovieQuiz

class ArryTest: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 2, 3, 4, 5]
        // When
        let value = array[safe: 10]
        // Then
        XCTAssertNil(value)
        
    }
}
