//
//  ReportView.swift
//  ExpenseTrackerAI
//
//  Created by Dhruv Chhatbar on 14/09/25.
//

import SwiftUI
import Charts

struct ExpenseChartView: View {
    let monthlyData: [(month: String, total: Double)]
    var body: some View {
        Chart {
            ForEach(monthlyData, id: \.month) { data in
                BarMark(
                    x: .value("Month", data.month),
                    y: .value("Total", data.total)
                )
                .foregroundStyle(.blue.gradient)
            }
        }
        .chartYAxisLabel("Expense")
        .chartXAxisLabel("Month")
    }
}

struct CategoryChartView: View {
    let categoryData: [(category: String, total: Double)]
    
    var body: some View {
        Chart {
            ForEach(categoryData, id: \.category) { data in
                BarMark(
                    x: .value("Category", data.category),
                    y: .value("Total", data.total)
                )
                .foregroundStyle(.green.gradient)
            }
        }
        .chartYAxisLabel("Expense")
        .chartXAxisLabel("Category")
    }
}

struct ExpenseTrendChart: View {
    let trendData: [Expense]  // raw expenses
    
    // Compute monthly totals inside the view
    private var monthlyTotals: [(month: String, total: Double)] {
        let grouped = Dictionary(grouping: trendData) { expense -> String in
            let comps = Calendar.current.dateComponents([.year, .month], from: expense.date)
            return "\(comps.year!)-\(comps.month!)"
        }
        let totals = grouped.map { (key, group) in
            (month: key, total: group.reduce(0) { $0 + $1.amount })
        }
        return totals.sorted { $0.month < $1.month }
    }
    
    var body: some View {
        Chart {
            ForEach(monthlyTotals, id: \.month) { data in
                LineMark(
                    x: .value("Month", data.month),
                    y: .value("Total", data.total)
                )
                .foregroundStyle(.red.gradient)
                .symbol(Circle())
            }
        }
        .chartYAxisLabel("Expense")
        .chartXAxisLabel("Month")
    }
}


struct CategoryBreakdownChart: View {
    let expenses: [Expense]

    // Group expenses by category
    var categoryTotals: [(String, Double)] {
        Dictionary(grouping: expenses, by: { $0.category })
            .map { (key, values) in
                (key, values.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.1 > $1.1 } // sort by amount
    }

    var body: some View {
        Chart {
            ForEach(categoryTotals, id: \.0) { category, total in
                BarMark(
                    x: .value("Total", total),
                    y: .value("Category", category)
                )
                .foregroundStyle(by: .value("Category", category))
            }
        }
        .frame(height: 300)
        .padding()
        .navigationTitle("Category Breakdown")
    }
}
struct ReportsView: View {
    @StateObject private var viewModel = ExpenseTrackerViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExpenseTrendChart(trendData: viewModel.expenses)
                CategoryBreakdownChart(expenses: viewModel.expenses)
            }
            .padding()
        }
        .navigationTitle("Reports")
    }
}

//struct ReportsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportsView(expenses: [
//            Expense(id: "1", userId:"1", title: "Groceries", amount: 150.75, currency: "INR", category: "Food", date: Date(), createdAt: Timestamp(date: Date()), receiptURL: ""),
//            Expense(id: "2", userId:"2",title: "Work travel", note: "Uber", amount: 320.50, currency: "INR", category: "Transport", date: Date(), createdAt: Timestamp(date: Date()), receiptURL: ""),
//            Expense(id: "3", userId:"3",title: "Netflix", note: "Monthly subscription", amount: 499.00, currency: "INR", category: "Entertainment", date: Date().addingTimeInterval(-86400 * 7), createdAt: Timestamp(date: Date().addingTimeInterval(-86400 * 7)), receiptURL: ""),
//        ])
//    }
//}
