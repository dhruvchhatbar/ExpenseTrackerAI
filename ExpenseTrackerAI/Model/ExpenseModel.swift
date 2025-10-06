//
//  ExpenseModel.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 14/09/25.
//


import Foundation
import FirebaseFirestore

struct Expense: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var note: String?
    var amount: Double
    var currency: String
    var category: String
    var date: Date
    @ServerTimestamp var createdAt: Timestamp?
    var receiptURL: String?
}
