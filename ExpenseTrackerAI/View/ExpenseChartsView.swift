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
    
    // Helper function to get category icons
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "groceries", "food", "dining out":
            return "cart.fill"
        case "transportation", "transport":
            return "car.fill"
        case "bills & utilities", "utilities":
            return "bolt.fill"
        case "loan emi", "loan":
            return "banknote.fill"
        case "entertainment":
            return "tv.fill"
        case "shopping":
            return "bag.fill"
        case "healthcare", "health":
            return "cross.fill"
        case "other":
            return "ellipsis.circle.fill"
        default:
            return "tag.fill"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient matching the theme
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.722, blue: 0.271),
                        Color(red: 1.0, green: 0.97, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // AI Predictions Card
                        let sortedPredictions = vm.nextMonthCategoryPrediction.sorted { $0.key < $1.key }
                        if !sortedPredictions.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "brain.head.profile")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                        .padding(8)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("AI Predictions")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text("Next Month Forecast")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack(spacing: 12) {
                                    ForEach(sortedPredictions, id: \.key) { item in
                                        let key = item.key
                                        let value = item.value
                                        
                                        HStack {
                                            // Category icon
                                            Image(systemName: categoryIcon(for: key))
                                                .foregroundColor(.white)
                                                .font(.title3)
                                                .frame(width: 24)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(key)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.white)
                                                
                                                Text("\(Int(round(value.frequency))) transactions")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing, spacing: 2) {
                                                Text("₹\(value.total, specifier: "%.0f")")
                                                    .font(.headline)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(.white)
                                                
                                                Text("predicted")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.15))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.yellow.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                            .padding(.horizontal)
                        }
                        
                        // Monthly totals
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                
                                Text("Monthly Totals")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            ExpenseChartView(monthlyData: vm.monthlyTotalsForChart())
                                .frame(height: 250)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Trend line
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                
                                Text("Expense Trend")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            ExpenseTrendChart(trendData: vm.monthlyTotalsForTrend())
                                .frame(height: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.8), Color.red.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Category totals
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .padding(8)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                                
                                Text("Category Breakdown")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            CategoryChartView(categoryData: vm.categoryTotals())
                                .frame(height: 200)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [Color.green.opacity(0.8), Color.green.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Analytics & Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
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

