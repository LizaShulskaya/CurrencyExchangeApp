import SwiftUI
import SwiftData
import CurrencyDatabase

@main
struct CurrencyConverterApp: App {
    private let container = try! ModelContainer(for: ExchangeRateCache.self,
                                                ConversionHistoryRecord.self)
    
    var body: some Scene {
        WindowGroup {
            ConverterView()
                .modelContainer(container) 
        }
    }
}
