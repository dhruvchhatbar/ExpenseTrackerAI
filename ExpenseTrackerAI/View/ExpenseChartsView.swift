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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Monthly totals
                    ExpenseChartView(monthlyData: vm.monthlyTotalsForChart())
                        .frame(height: 250)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.orange.opacity(0.1)))
                    
                    // Trend line
                    ExpenseTrendChart(trendData: vm.monthlyTotalsForTrend())
                        .frame(height: 200)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.red.opacity(0.1)))
                    
                    // Category totals
                    CategoryChartView(categoryData: vm.categoryTotals())
                        .frame(height: 200)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 16).fill(.green.opacity(0.1)))
                }
                .padding(.vertical)
            }
            .navigationTitle("Charts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    @Environment(\.dismiss) var dismiss
}

