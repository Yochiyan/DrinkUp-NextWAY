//
//  HistoryView.swift
//  DrinkUp
//
//  Created by よっちゃん on 2026/02/14.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    var records: [DrinkRecord]

    var body: some View {
        NavigationStack {
            List {
                ForEach(dailySummaries(), id: \.date) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.date.formatted(date: .complete, time: .omitted))
                                .font(.headline)

                            Text("Total: \((item.total)) ml")
                                .font(.title3)
                                .bold()
                        }

                        Spacer()

                        // Stamp indicator
                        stampView(for: item.total)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("History")
            .overlay(alignment: .bottomLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName:"chevron.down")
                        .bold()
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .padding([.leading, .bottom], 16)
            }
        }
    }
    

    private func dailySummaries() -> [(date: Date, total: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let firstDate = records.map({ calendar.startOfDay(for: $0.date) }).min() else {
            return []
        }

        var date = firstDate
        var results: [(date: Date, total: Int)] = []

        while date <= today {
            let total = records
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.amount }

            results.append((date: date, total: total))

            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }

        return results.sorted { $0.date > $1.date }
    }

    
    @ViewBuilder
    private func stampView(for total: Int) -> some View {
        if (0...499).contains(total) {
            Image(systemName: "leaf")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 50))
                .foregroundColor(.red)

        } else if (500...799).contains(total) {
            Image(systemName: "leaf.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 50))
                .foregroundColor(.yellow)

        } else if (800...1199).contains(total) {
            Image(systemName: "tree.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 50))
                .foregroundColor(.green)

        } else if total >= 1200 {
            Image(systemName: "trophy.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 50))
                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))

        } else {
            Image(systemName: "questionmark.circle")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 36))
                .foregroundColor(.gray)
        }
    }
}

