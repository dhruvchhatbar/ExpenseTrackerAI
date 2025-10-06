//
//  ExpenseListView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 15/09/25.
//

import SwiftUI

struct ExpensesListView: View {
    @StateObject private var vm = ExpenseTrackerViewModel()
    @State private var showingAdd = false
    @State private var showCharts = false

    var body: some View {
        NavigationView {
            ZStack {

                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - AI Insights Card
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
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            Text("Next Month Total Prediction: ₹\(vm.nextMonthPrediction, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)

                        // MARK: - Expenses List as Crystal Cards
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(vm.expenses) { expense in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(expense.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(expense.currency)\(expense.amount, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.yellow)
                                    }
                                    HStack {
                                        Text(expense.category)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                        Spacer()
                                        if let note = expense.note {
                                            Text(note)
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.orange.opacity(0.8), Color.orange.opacity(0.5)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .background(.ultraThinMaterial)
                                        .shadow(color: Color.orange.opacity(0.3), radius: 10, x: 0, y: 5)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Expense Tracker")
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
        }
    }
}

struct ExpenseListView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesListView()
            .preferredColorScheme(.dark)
    }
}
