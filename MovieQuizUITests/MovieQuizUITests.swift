import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
        
    }
    
    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func tapButton(nameButton: String, qtyTaps: Int) {
        for _ in 1...qtyTaps {
            sleep(1)
            app.buttons[nameButton].tap()
            sleep(3)
        }
    }
    
    func testButtonYes() throws {
        sleep(2)
        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        
        tapButton(nameButton: "Yes", qtyTaps: 1)
        sleep(2)
        
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testButtonNo() throws {
        sleep(2)
        let firstPoster = app.images["Poster"].screenshot().pngRepresentation
        
        tapButton(nameButton: "Yes", qtyTaps: 1)
        
        let secondPoster = app.images["Poster"].screenshot().pngRepresentation
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testLabelTextIsChange() throws {
        sleep(2)
        let firstLabeltextQuestion = app.staticTexts["IndexLabel"].label
        
        tapButton(nameButton: "No", qtyTaps: 1)
        
        let secondLabeltextQuestion = app.staticTexts["IndexLabel"].label
        
        XCTAssertEqual(firstLabeltextQuestion, "1/10")
        XCTAssertEqual(secondLabeltextQuestion, "2/10")
    }
    
    func testResultAlert() throws {
        tapButton(nameButton: "No", qtyTaps: 10)
        
        let alertResult = app.alerts["Game results"]
        
        XCTAssertTrue(alertResult.exists)
        XCTAssertTrue(alertResult.label == "Этот раунд окончен!")
        XCTAssertTrue(alertResult.buttons.firstMatch.label == "Сыграть еще раз")
    }
}
