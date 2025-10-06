//
//  AddExpenseView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

//
//  AddExpenseView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

//
//  AddExpenseView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: ExpenseTrackerViewModel
    
    // MARK: - Form fields
    @State private var title = ""
    @State private var note = ""
    @State private var amount = ""
    @State private var selectedCategory: String = "Groceries"
    @State private var customCategory = ""
    @State private var predictedCategory: String?
    @State private var currency = "₹"
    
    private let predefinedCategories = [
        "Groceries",
        "Transportation",
        "Bills & Utilities",
        "Loan EMI",
        "Dining Out",
        "Entertainment",
        "Shopping",
        "Healthcare",
        "Other"
    ]
    
    // MARK: - Computed property for final category
    private var finalCategory: String {
        if selectedCategory == "Other" {
            return customCategory.isEmpty ? "Other" : customCategory
        } else {
            return selectedCategory
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                detailsSection
            }
            .navigationTitle("New Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: saveExpense)
                }
            }
            // MARK: - Observers
            .onChange(of: amount) { _ in predictCategory() }
            .onChange(of: note) { _ in predictCategory() }
            .onChange(of: vm.predictedCategory) { newValue in
                updatePredictedCategory(newValue)
            }
        }
    }
    
    // MARK: - Form Section
    private var detailsSection: some View {
        Section("Details") {
            TextField("Title", text: $title)
            TextField("Note", text: $note)
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(predefinedCategories, id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .pickerStyle(.menu)
            
            if selectedCategory == "Other" {
                TextField("Custom Category", text: $customCategory)
            }
            
            Picker("Currency", selection: $currency) {
                Text("₹").tag("₹")
                Text("$").tag("$")
                Text("€").tag("€")
            }
            .pickerStyle(.segmented)
            
            if let cat = predictedCategory {
                Text("Predicted category: \(cat)")
                    .foregroundColor(.blue)
            }
        }
    }
    
    // MARK: - Save expense
    private func saveExpense() {
        guard let amt = Double(amount) else { return }
        
        let expense = Expense(
            id: nil,
            userId: "currentUserId", // replace with actual user ID
            title: title,
            note: note.isEmpty ? nil : note,
            amount: amt,
            currency: currency,
            category: finalCategory,
            date: Date(),
            createdAt: nil,
            receiptURL: nil
        )
        
        vm.addExpense(expense)
        dismiss()
    }
    
    // MARK: - Category prediction helpers
    private func predictCategory() {
        guard let amt = Double(amount), !note.isEmpty else { return }
        vm.predictCategory(amount: amt, description: note)
        predictedCategory = vm.predictedCategory
    }
    
    private func updatePredictedCategory(_ newValue: String?) {
        guard let cat = newValue else { return }
        if predefinedCategories.contains(cat) {
            selectedCategory = cat
            customCategory = ""
        } else {
            selectedCategory = "Other"
            customCategory = cat
        }
        predictedCategory = cat
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(vm: ExpenseTrackerViewModel())
    }
}
