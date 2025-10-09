//
//  ExpenseViewModel.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 15/09/25.
//

import SwiftUI
import FirebaseFirestore
import CoreML
import UIKit
struct Prediction {
    let frequency: Double
    let total: Double
}
class ExpenseTrackerViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var predictedCategory: String?
    @Published var nextMonthPrediction: Double = 0
    @Published var nextMonthCategoryPrediction: [String: Prediction] = [:]
    @Published var currentUserId: String?
    
    var sortedCategoryPredictions: [(String, Prediction)] {
        nextMonthCategoryPrediction.sorted { $0.key < $1.key }
    }

    private let db = Firestore.firestore()
    private var model: ExpenseCategoryClassifier? // read-only
    private var listener: ListenerRegistration?
    
    init() {
        loadModel()
        setupDeviceUser()
    }
    
    deinit {
        listener?.remove()
    }
    
    private func setupDeviceUser() {
        // Create a unique device-based user ID
        currentUserId = getOrCreateDeviceUserId()
        if let userId = currentUserId {
            fetchExpenses(for: userId)
        }
    }
    
    private func getOrCreateDeviceUserId() -> String {
        let key = "device_user_id"
        
        // Check if we already have a user ID stored
        if let existingUserId = UserDefaults.standard.string(forKey: key) {
            return existingUserId
        }
        
        // Create a new unique user ID for this device
        let newUserId = "device_\(UUID().uuidString)"
        UserDefaults.standard.set(newUserId, forKey: key)
        return newUserId
    }
    private func loadModel() {
        do {
            model = try ExpenseCategoryClassifier(configuration: .init())
        } catch {
            print(" Failed to load model: (error)")
        }
    }
    func fetchExpenses(for userId: String? = nil) {
        guard let userId = userId ?? currentUserId else {
            print("No user ID available for fetching expenses")
            return
        }
        
        // Remove existing listener if any
        listener?.remove()
        
        let query: Query = db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            
        listener = query.addSnapshotListener { snapshot, error in
            if let error = error {
                print("Fetch error: \(error)")
                return
            }
            
            let newExpenses = snapshot?.documents.compactMap {
                try? $0.data(as: Expense.self)
            } ?? []
            
            print("Firebase listener triggered. Found \(newExpenses.count) expenses")
            if !newExpenses.isEmpty {
                print("Latest expense: \(newExpenses.first?.title ?? "Unknown")")
            }
            
            self.expenses = newExpenses
            self.computeAIInsights()
        }
    }
    func addExpense(_ expense: Expense) {
        guard let userId = currentUserId else {
            print("No user ID available for adding expense")
            return
        }
        
        var expenseWithUserId = expense
        expenseWithUserId.userId = userId
        
        print("Adding expense: \(expenseWithUserId.title) for user: \(userId)")
        
        do {
            _ = try db.collection("expenses").addDocument(from: expenseWithUserId)
            print("Expense added successfully to Firestore")
        } catch {
            print("Add error: \(error)")
        }
    }
    func deleteExpense(_ expense: Expense) {
        guard let id = expense.id else { return }
        db.collection("expenses").document(id).delete()
    }
    
    // MARK: - User Management Helpers
    func createNewUser() {
        // Create a new device user ID
        currentUserId = getOrCreateDeviceUserId()
        if let userId = currentUserId {
            fetchExpenses(for: userId)
        }
    }
    
    func switchUser() {
        // Clear current user and create a new one
        UserDefaults.standard.removeObject(forKey: "device_user_id")
        currentUserId = nil
        expenses = []
        createNewUser()
    }
    
    func isUserSignedIn() -> Bool {
        return currentUserId != nil
    }
    
    // MARK: - Manual refresh method
    func refreshExpenses() {
        if let userId = currentUserId {
            fetchExpenses(for: userId)
        }
    }
    func predictCategory(amount: Double, description: String) {
        guard let model = model else { return }
        let input = ExpenseCategoryClassifierInput(amount: Int64(amount), title: description)
        do {
            let prediction = try model.prediction(input: input)
            predictedCategory = prediction.category
        } catch {
            print(" Prediction failed: (error)")
        }
    }
    // MARK: - Chart helpers
    func monthlyTotals() -> [(month: String, total: Double)] {
        let grouped = Dictionary(grouping: expenses) { expense -> String in
            let comps = Calendar.current.dateComponents([.year, .month], from: expense.date)
            return "(comps.year!)-(comps.month!)"
        }
        let totals = grouped.map { (key, group) in
            (month: key, total: group.reduce(0) { $0 + $1.amount })
        }.sorted { $0.month < $1.month }
        return totals
    }
    func categoryTotals() -> [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        let totals = grouped.map { (key, group) in
            (category: key, total: group.reduce(0) { $0 + $1.amount })
        }.sorted { $0.category < $1.category }
        return totals
    }
    func expenseTrendData() -> [(month: String, total: Double)] {
        return monthlyTotals()
    }
    // Returns monthly totals for charts
    func monthlyTotalsForChart() -> [(month: String, total: Double)] {
        // Group expenses by year-month
        let grouped = Dictionary(grouping: expenses) { expense -> String in
            let comps = Calendar.current.dateComponents([.year, .month], from: expense.date)
            let monthString = String(format: "%02d", comps.month ?? 0)
            return monthString
        }
        // Sum totals for each month
        let totals = grouped.map { (key, group) in
            (month: key, total: group.reduce(0) { $0 + $1.amount })
        }
        // Sort by month ascending
        return totals.sorted { $0.month < $1.month }
    }
    // If you want the raw Expense array for trend chart
    func monthlyTotalsForTrend() -> [Expense] {
        return expenses.sorted { $0.date < $1.date }
    }
    // MARK: - AI Insights
    private func computeAIInsights() {
        // Define recurring categories with their expected frequency patterns
        let recurringCategories = ["Groceries", "Bills & Utilities", "Loan EMI"]
        
        // Categories that typically occur once per month (EMI, Bills)
        let monthlyOnceCategories = ["Bills & Utilities", "Loan EMI"]
        
        // 1️⃣ Compute monthly totals for recurring categories only
        let recurringExpenses = expenses.filter { recurringCategories.contains($0.category) }
        
        let monthlyGroups = Dictionary(grouping: recurringExpenses) { expense in
            let comps = Calendar.current.dateComponents([.year, .month], from: expense.date)
            return "\(comps.year!)-\(String(format: "%02d", comps.month!))"
        }
        
        // Sort months chronologically
        let sortedMonthly = monthlyGroups.sorted { $0.key < $1.key }
        let monthlyTotals = sortedMonthly.map { $0.value.reduce(0) { $0 + $1.amount } }
        
        // 2️⃣ Predict next month total using weighted average of last few months
        let lastN = 3 // Use last 3 months for trend (adjustable)
        let recentTotals = monthlyTotals.suffix(lastN)
        
        // Compute simple growth rate based on percentage change
        var predictedTotal: Double = 0
        if recentTotals.count >= 2 {
            var growthRates: [Double] = []
            for i in 1..<recentTotals.count {
                let prev = recentTotals[i-1]
                let curr = recentTotals[i]
                if prev != 0 {
                    growthRates.append((curr - prev) / prev)
                }
            }
            let avgGrowthRate = growthRates.isEmpty ? 0 : growthRates.reduce(0, +) / Double(growthRates.count)
            predictedTotal = recentTotals.last! * (1 + avgGrowthRate)
        } else if let last = recentTotals.last {
            predictedTotal = last // Only 1 month of data
        } else {
            predictedTotal = 0 // No data
        }
        
        // 3️⃣ Compute category-wise monthly totals and counts for recurring categories only
        var categoryMonthlyTotals: [String: [String: Double]] = [:]
        var categoryMonthlyCounts: [String: [String: Int]] = [:]
        
        for expense in recurringExpenses {
            let comps = Calendar.current.dateComponents([.year, .month], from: expense.date)
            let monthKey = "\(comps.year!)-\(String(format: "%02d", comps.month!))"
            categoryMonthlyTotals[expense.category, default: [:]][monthKey, default: 0] += expense.amount
            categoryMonthlyCounts[expense.category, default: [:]][monthKey, default: 0] += 1
        }
        
        // 4️⃣ Predict next month per-category with different logic for different types
        var predictions: [String: Prediction] = [:]
        
        for category in recurringCategories {
            // Check if this category has any historical data
            guard let totalsByMonth = categoryMonthlyTotals[category],
                  !totalsByMonth.isEmpty else {
                // If no historical data, skip this category
                continue
            }
            
            let countsByMonth = categoryMonthlyCounts[category] ?? [:]
            let sortedTotals = totalsByMonth.sorted{$0.key < $1.key}.map({$0.value})
            let recentTotals = sortedTotals.suffix(lastN)
                        
                var growthRates: [Double] = []
                for i in 1..<recentTotals.count {
                    let prev = recentTotals[i-1]
                    let curr = recentTotals[i]
                    if prev != 0 {
                        growthRates.append((curr - prev) / prev)
                    }
                }
            
            // Predict frequency based on category type
            var predictedFreq: Double = 0
            
            if monthlyOnceCategories.contains(category) {
                // For EMI and Bills: typically once per month
                predictedFreq = 1.0
            } else {
                // For Groceries and Transportation: calculate based on historical frequency
                let sortedCounts = countsByMonth.sorted{ $0.key < $1.key}.map({$0.value})
                let recentCounts = sortedCounts.suffix(lastN)
                
                if recentCounts.count >= 2 {
                    var growthRates: [Double] = []
                    for i in 1..<recentCounts.count {
                        let prev = Double(recentCounts[i-1])
                        let curr = Double(recentCounts[i])
                        if prev != 0 {
                            growthRates.append((curr - prev) / prev)
                        }
                    }
                    let avgGrowth = growthRates.isEmpty ? 0 : growthRates.reduce(0, +) / Double(growthRates.count)
                    predictedFreq = Double(recentCounts.last!) * (1 + avgGrowth)
                } else if let last = recentCounts.last {
                    predictedFreq = Double(last)
                } else {
                    predictedFreq = 0
                }
                
                // Ensure minimum frequency for multiple-occurrence categories
                predictedFreq = max(1, predictedFreq)
            }
            
            predictions[category] = Prediction(frequency: predictedFreq, total: max(0, predictedTotal))
        }
        
        nextMonthCategoryPrediction = predictions
        // Update total prediction to sum of category predictions for consistency
        nextMonthPrediction = predictions.values.reduce(0) { $0 + $1.total }
    }
}
