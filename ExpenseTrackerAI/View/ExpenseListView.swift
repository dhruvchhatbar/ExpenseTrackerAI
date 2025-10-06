//
//  ExpenseListView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 15/09/25.
//

import Foundation
import SwiftUI
struct ExpensesListView: View {
    @StateObject private var vm = ExpenseTrackerViewModel()
    @State private var showingAdd = false
    @State private var showCharts = false
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(colors: [Color("LightBlue"), Color("LightPurple")],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // AI Insights Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("AI Insights")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { showCharts = true }) {
                                    Label("Charts", systemImage: "chart.bar.fill")
                                        .font(.subheadline)
                                        .padding(6)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            Text("Next Month Total Prediction: ₹\(vm.nextMonthPrediction, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                            let sortedPredictions = vm.nextMonthCategoryPrediction.sorted { $0.key < $1.key }
                            ForEach(sortedPredictions, id: \.key) { item in
                                let key = item.key
                                let value = item.value
                                Text("\(key): \(Int(round(value.frequency)))x ₹\(value.total, specifier: "%.2f")")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }

                        }
                        .padding()
                        .background(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 4)
                        .padding(.horizontal)
                        // Expenses List as Cards
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(vm.expenses) { expense in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(expense.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(expense.currency)\(expense.amount, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                    HStack {
                                        Text(expense.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        if let note = expense.note {
                                            Text(note)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .padding()
                                .background(.white.opacity(0.9))
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("My Expenses")
            .toolbar {
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddExpenseView(vm: vm)
            }
            .sheet(isPresented: $showCharts) {
                ExpenseChartsView(vm: vm)
            }
            .background(LinearGradient(colors: [.orange.opacity(0.5), .orange], startPoint: .top, endPoint: .bottom),
            )
        }
    }
}
struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesListView()
    }
}
