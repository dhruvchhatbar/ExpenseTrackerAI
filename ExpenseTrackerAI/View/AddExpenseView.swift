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
            ZStack {
                Color.clear
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Form Fields
                        VStack(spacing: 20) {
                            formField(title: "Title", text: $title, placeholder: "Enter expense title")
                            formField(title: "Note", text: $note, placeholder: "Add a note (optional)")
                            amountField
                            categorySection
                            Button("Save Expense", action: saveExpense)
                                .fontWeight(.semibold)
                                .foregroundColor(.white )
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.orange)
                                .cornerRadius(20)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.white, Color(red: 1.0, green: 0.96, blue: 0.88)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.orange.opacity(0.1), radius: 6, x: 0, y: 3)
//                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            // Make navigation bar transparent using toolbarBackground API
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }
            // MARK: - Observers
            .onChange(of: amount) { oldValue, newValue in predictCategory() }
            .onChange(of: note) { oldValue, newValue in predictCategory() }
            .onChange(of: vm.predictedCategory) { oldValue,newValue in
                updatePredictedCategory(newValue)
            }
        }
    }
    
    // MARK: - Custom Form Components
    private func formField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
            
            TextField(placeholder, text: text)
                .textFieldStyle(CustomTextFieldStyle())
        }
    }
    
    private var amountField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Amount")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack {
                Text(currency)
                    .font(.title2)
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
                
                TextField("0.00", text: $amount)
                    .textFieldStyle(CustomTextFieldStyle())
                    .keyboardType(.decimalPad)
            }
        }
    }
    
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.headline)
                .foregroundColor(.black)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(predefinedCategories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedCategory == category ? .white : .black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                selectedCategory == category ? 
                                Color.orange : Color.gray.opacity(0.1)
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedCategory == category ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            
            if selectedCategory == "Other" {
                TextField("Custom Category", text: $customCategory)
                    .textFieldStyle(CustomTextFieldStyle())
            }
        }
    }

    
    // MARK: - Save expense
    private func saveExpense() {
        guard let amt = Double(amount), !title.isEmpty else { return }
        
        let expense = Expense(
            id: nil,
            userId: vm.currentUserId ?? "unknown",
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
        
        // Add a small delay to ensure Firebase has processed the data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            vm.refreshExpenses()
        }
        
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

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
            .font(.body)
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView(vm: ExpenseTrackerViewModel())
    }
}
