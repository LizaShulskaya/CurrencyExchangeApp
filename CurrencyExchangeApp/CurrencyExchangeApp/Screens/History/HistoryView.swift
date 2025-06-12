import SwiftUI
import SwiftData
import CurrencyDatabase

/**
 Экран истории конверсий.
 
 Реализует отображении всех выполненных конвертаций и реализует поиск по валютной паре.
 */

struct HistoryView: View {
    @State private var searchText: String = ""
    
    // Запрашиваем все записи, отсортированные по дате 
    @Query(
        sort: [ SortDescriptor<ConversionHistoryRecord>(\.date, order: .reverse) ]
    )
    private var allRecords: [ConversionHistoryRecord]
    
    private var filteredRecords: [ConversionHistoryRecord] {
        guard !searchText.isEmpty else {
            return allRecords
        }
        return allRecords.filter { record in
            let pair = record.fromCurrency + "/" + record.toCurrency
            return pair.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredRecords) { record in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(record.fromCurrency) → \(record.toCurrency)")
                        .font(.headline)
                    Text("\(record.amount, specifier: "%.2f") → \(record.result, specifier: "%.2f")")
                    Text("\(Strings.rateLabelTitle) \(record.rate, specifier: "%.4f")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(record.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle(Strings.historyNavigationTitle)
        .searchable(text: $searchText, prompt: Strings.searchPlaceholder)
    }
}
