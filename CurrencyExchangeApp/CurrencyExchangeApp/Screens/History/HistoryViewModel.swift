import SwiftUI

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var searchText: String = ""
}
