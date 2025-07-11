import SwiftUI
import SwiftData
import CurrencyRateService
import CurrencyAPI

/**
 Экран конвертера валют.
 
 При изменении суммы или валют автоматически запускается пересчет через ViewModel.
 */
struct ConverterView: View {
    @ObservedObject private var viewModel: ConverterViewModel
    
    init(viewModel: ConverterViewModel) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Ввод
                VStack(spacing: 8) {
                    HStack {
                        Text("\(Strings.amountLabelTitle), \(viewModel.fromCurrency.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)

                    HStack(spacing: 12) {
                        TextField(Strings.zero, text: $viewModel.amount)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)

                        Picker("", selection: $viewModel.fromCurrency) {
                            ForEach(Currency.allCases) { c in
                                Text("\(c.rawValue) \(c.flag)").tag(c)
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
                        Text("\(Strings.amountLabelTitle), \(viewModel.toCurrency.rawValue)")
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
                                Text("\(c.rawValue) \(c.flag)").tag(c)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    .padding(.horizontal)
                }

                // Курс
                if let rate = viewModel.rate {
                    Text("\(Strings.rateLabelTitle) 1 \(viewModel.fromCurrency.rawValue) = \(rate, specifier: "%.4f") \(viewModel.toCurrency.rawValue)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .navigationTitle(Strings.converterNavigationTitle)
            .padding(.top)
            // Автоматически запускаем расчёт при изменении любого из полей
            .onChange(of: viewModel.amount) { newValue in
                let filtered = filterAmountInput(newValue)
                if filtered != newValue {
                    viewModel.amount = filtered
                } else {
                    Task { await viewModel.convert() }
                }
            }
            .onChange(of: viewModel.fromCurrency) {
                Task { await viewModel.convert() }
            }
            .onChange(of: viewModel.toCurrency) {
                Task { await viewModel.convert() }
            }
            .toolbar {
                NavigationLink(destination: HistoryView()) {
                    Image(systemName: "clock.fill")
                }
            }
        }
      
    }
    
    private func filterAmountInput(_ input: String) -> String {
        var result = ""
        var hasDecimalPoint = false
        var digitsAfterDecimal = 0

        for char in input {
            if char.isWholeNumber {
                if hasDecimalPoint {
                    if digitsAfterDecimal < 2 {
                        result.append(char)
                        digitsAfterDecimal += 1
                    }
                } else {
                    result.append(char)
                }
            } else if char == "." && !hasDecimalPoint {
                result.append(char)
                hasDecimalPoint = true
            }
    
            if result.count >= 15 {
                break
            }
        }

        return result
    }

    
}
