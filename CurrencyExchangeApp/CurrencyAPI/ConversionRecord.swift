import Foundation

/**
 Модель записи истории конвертации валют.
 */
public struct ConversionRecord: Identifiable, Codable {
    public var id: UUID
    let from: Currency
    let to: Currency
    let amount: Double
    let result: Double
    let rate: Double
    let date: Date
}
