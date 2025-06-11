import SwiftUI
import SwiftData
import CoreModels

struct ConverterView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ConverterViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Ввод
                VStack(spacing: 8) {
                    HStack {
                        Text("Сумма, \(viewModel.fromCurrency.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        TextField("0", text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)

                        Picker("", selection: $viewModel.fromCurrency) {
                            ForEach(Currency.allCases) { c in
                                Text(c.flag).tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    .padding(.horizontal)
                }

                // Результат
                VStack(spacing: 8) {
                    HStack {
                        Text("Сумма, \(viewModel.toCurrency.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        Text(viewModel.resultText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)

                        Picker("", selection: $viewModel.toCurrency) {
                            ForEach(Currency.allCases) { c in
                                Text(c.flag).tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    .padding(.horizontal)
                }

                // Курс
                if let rate = viewModel.rate {
                    Text("Курс: 1 \(viewModel.fromCurrency.rawValue) = \(rate, specifier: "%.4f") \(viewModel.toCurrency.rawValue)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .navigationTitle("Конвертер валют")
            .padding(.top)
            // Автоматически запускаем расчёт при изменении любого из полей
            .onChange(of: viewModel.amount) { _ in
                Task { await viewModel.convert(context: modelContext) }
            }
            .onChange(of: viewModel.fromCurrency) { _ in
                Task { await viewModel.convert(context: modelContext) }
            }
            .onChange(of: viewModel.toCurrency) { _ in
                Task { await viewModel.convert(context: modelContext) }
            }
        }
    }
}
