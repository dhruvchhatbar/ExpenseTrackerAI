//
//  ExpenseChartsView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 20/09/25.
//

import SwiftUI
import Charts

struct ExpenseChartsView: View {
    @ObservedObject var vm: ExpenseTrackerViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(colors: [Color("LightBlue"), Color("LightPurple")],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Predictions List
                        let sortedPredictions = vm.nextMonthCategoryPrediction.sorted { $0.key < $1.key }
                        if !sortedPredictions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Next Month Predictions")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                ForEach(sortedPredictions, id: \.key) { item in
                                    let key = item.key
                                    let value = item.value
                                    HStack {
                                        Text(key)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                        Spacer()
                                        Text("\(Int(round(value.frequency)))x ₹\(value.total, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .bold()
                                            .foregroundColor(.orange)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Monthly totals
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Totals")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            ExpenseChartView(monthlyData: vm.monthlyTotalsForChart())
                                .frame(height: 250)
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.orange.opacity(0.2))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        
                        // Trend line
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Expense Trend")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            ExpenseTrendChart(trendData: vm.monthlyTotalsForTrend())
                                .frame(height: 200)
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.red.opacity(0.2))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                        
                        // Category totals
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category Breakdown")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            
                            CategoryChartView(categoryData: vm.categoryTotals())
                                .frame(height: 200)
                        }
                        .padding(.horizontal)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.green.opacity(0.2))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Charts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}



struct ExpenseChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseChartsView(vm: ExpenseTrackerViewModel())
    }
}

