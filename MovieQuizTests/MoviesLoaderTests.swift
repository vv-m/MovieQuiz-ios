import XCTest

@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoadind() throws {
        // Given
        let loader = MoviesLoader()
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
        }
        
        // Then
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        
        // When
        
        // Then
        
    }
}
