//
//  DashCardView.swift
//  Subscription Reaper
//
//  Created by Anoop Jose on 17/12/2025.
//

import SwiftUI

struct DashCardView: View {
    @Namespace private var glassNamespace
    var title: String = "Upcoming Total"
    var subtitle: String? = "Next 30 Days"
    var amount: String = "$124.99"
    var icon: String = "creditcard.fill"
    var tint: Color = .blue

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header row
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary.opacity(0.9))
                    
                    if let subtitle {
                        Text(subtitle.uppercased())
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                tint.opacity(0.6)
                                    .shadow(.inner(color: .white.opacity(0.3), radius: 1, x: 0, y: 1))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }

                Spacer(minLength: 12)

                // Amount Section
                VStack(alignment: .leading, spacing: 6) {
                    Text(amount)
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    if let annual = annualEstimateString() {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 14, weight: .bold))
                            Text("\(annual) / year")
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                        .foregroundStyle(.primary.opacity(0.6))
                    }
                }
            }

            Spacer(minLength: 16)

            // Right side: Icon/Visual
            VStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.3), tint.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.4), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(tint)
                        .shadow(color: tint.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .frame(width: 56, height: 56)
                
                Spacer()
            }
        }
        .padding(28)
        .frame(height: 160)
        .liquidGlassCard(tint: tint, cornerRadius: 32, id: "dash_card_main", in: glassNamespace)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: amount)
    }

    // Compute an annual estimate by parsing the monthly amount string
    private func annualEstimateString() -> String? {
        let trimmed = amount.trimmingCharacters(in: .whitespacesAndNewlines)

        let symbolPrefix = String(trimmed.prefix { !$0.isNumber && $0 != "." && $0 != "," })

        var numericString = trimmed
        let hasDot = numericString.contains(".")
        let hasComma = numericString.contains(",")
        if hasDot && hasComma {
            numericString = numericString.replacingOccurrences(of: ",", with: "")
        } else if hasComma && !hasDot {
            numericString = numericString.replacingOccurrences(of: ",", with: ".")
        }
        numericString = numericString.filter { ("0123456789." as String).contains($0) }

        guard let value = Double(numericString) else { return nil }
        let annual = value * 12.0

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if !symbolPrefix.isEmpty { formatter.currencySymbol = symbolPrefix }
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        return formatter.string(from: NSNumber(value: annual))
    }
}

// MARK: - Liquid Glass helper

private extension View {
    @ViewBuilder
    func liquidGlassCard(tint: Color = .blue, cornerRadius: CGFloat = 24, id: String? = nil, in namespace: Namespace.ID? = nil) -> some View {
        if #available(iOS 18.0, macOS 15.0, *), let id, let namespace {
            self
                .glassEffect(.clear.tint(tint.opacity(0.05)).interactive(), in: .rect(cornerRadius: cornerRadius))
                .glassEffectID(id, in: namespace)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1), .clear, .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: tint.opacity(0.05), radius: 20, x: 0, y: 10)
        } else if #available(iOS 18.0, macOS 15.0, *) {
            self
                .glassEffect(.clear.tint(tint.opacity(0.05)).interactive(), in: .rect(cornerRadius: cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1), .clear, .white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: tint.opacity(0.05), radius: 20, x: 0, y: 10)
        } else {
            self
                .background(
                    ZStack {
                        Rectangle()
                            .fill(.thinMaterial)
                        
                        LinearGradient(
                            colors: [tint.opacity(0.02), .clear, tint.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.05), .white.opacity(0.02)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
                .shadow(color: tint.opacity(0.08), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview("Liquid Glass Card") {
    ZStack {
        LinearGradient(colors: [.purple, .blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()

        VStack(spacing: 24) {
            DashCardView()
            DashCardView(title: "Active Subscriptions",
                         subtitle: "Currently",
                         amount: "£12.99",
                         icon: "list.bullet.rectangle.portrait.fill",
                         tint: .red)
            DashCardView(title: "Annual Savings",
                         subtitle: "Potential",
                         amount: "$420.00",
                         icon: "leaf.fill",
                         tint: .purple)
        }
        .padding(24)
    }
}

