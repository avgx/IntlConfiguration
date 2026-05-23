import Foundation
import Testing
@testable import IntlConfiguration

@Test func decodesMacroList() throws {
    let macros: [Macro] = try FixtureSupport.decode("macro-list")
    #expect(macros.count == 5)
    #expect(macros[0].description == "Start Recording")
}
