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
                LinearGradient(
                    colors: [
                        Color(red:1.0, green: 0.722, blue: 0.271),
                        Color(red: 1.0, green: 0.97, blue: 0.93)  // warm cream
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: - AI Insights Card
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())

                                Spacer()
                                Button(action: { showCharts = true }) {
                                    Label("Charts", systemImage: "chart.pie.fill")
                                        .font(.subheadline)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.white.opacity(0.25))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("AI Insights")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Next Month Prediction: ₹\(vm.nextMonthPrediction, specifier: "%.2f")")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.95))
                            }

                            Divider().background(Color.white.opacity(0.4))
                            
                            Text("Smart analysis suggests reduced spending on Food and Shopping next month.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.orange, Color.yellow.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(25)
                        .shadow(color: Color.orange.opacity(0.25), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)

                        // MARK: - Expenses List
                        VStack(spacing: 14) {
                            ForEach(vm.expenses) { expense in
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(expense.title)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            
                                            Text(expense.category)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(expense.currency)\(expense.amount, specifier: "%.2f")")
                                            .font(.headline)
                                            .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.3))
                                    }

                                    if let note = expense.note, !note.isEmpty {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundColor(.black.opacity(0.5))
                                    }
                                }
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color(red: 1.0, green: 0.96, blue: 0.88)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                                    )
                                )
                                .cornerRadius(18)
                                .shadow(color: Color.orange.opacity(0.1), radius: 6, x: 0, y: 3)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Expense Tracker")
            .toolbar {
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.orange)
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
