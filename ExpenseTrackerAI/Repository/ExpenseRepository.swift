//
//  ExpenseRepository.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 14/09/25.
//

import Foundation
import FirebaseFirestore

class ExpenseRepository: ObservableObject {
    private let db = Firestore.firestore()
    private let collection = "expenses"

    func addExpense(_ expense: Expense) async throws {
        if let id = expense.id {
            try db.collection(collection).document(id).setData(from: expense)
        } else {
            _ = try db.collection(collection).addDocument(from: expense)
        }
    }

    func updateExpense(_ expense: Expense) async throws {
        guard let id = expense.id else { throw NSError(domain: "ExpenseRepo", code: -1, userInfo: [NSLocalizedDescriptionKey:"Missing id"]) }
        try db.collection(collection).document(id).setData(from: expense, merge: true)
    }

    func deleteExpense(_ expense: Expense) async throws {
        guard let id = expense.id else { return }
        try await db.collection(collection).document(id).delete()
    }

    func fetchExpenses(for userId: String) async throws -> [Expense] {
        let snapshot = try await db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: Expense.self) }
    }
}
