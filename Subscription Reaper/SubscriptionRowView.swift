//
//  SubscriptionRowView.swift
//  Subscription Reaper
//

import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    
    private var dueTint: Color {
        let now = Date()
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.day], from: now, to: subscription.nextBillingDate).day ?? 100
        
        if diff <= 2 {
            return .red
        } else if diff <= 7 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon or Logo
            if let logoUrl = subscription.logoUrl, let url = URL(string: logoUrl) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32)
                } placeholder: {
                    Circle()
                        .fill(dueTint.opacity(0.1))
                        .frame(width: 44, height: 44)
                }
                .frame(width: 44, height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
            } else {
                Image(systemName: subscription.icon)
                    .font(.title2)
                    .foregroundStyle(dueTint)
                    .frame(width: 44, height: 44)
                    .background(dueTint.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.fullServiceName ?? subscription.name)
                    .font(.system(.headline, design: .rounded))
                
                HStack(spacing: 4) {
                    Text(subscription.nextBillingDate, format: .dateTime.month().day())
                    if dueTint != .blue {
                        Circle()
                            .fill(dueTint)
                            .frame(width: 6, height: 6)
                    }
                }
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(dueTint == .blue ? .secondary : dueTint)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.amount, format: .currency(code: subscription.currency))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text(subscription.frequency)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(dueTint.opacity(dueTint == .blue ? 0.1 : 0.3), lineWidth: 1)
        )
    }
}
