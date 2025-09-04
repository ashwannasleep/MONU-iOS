import SwiftUI

struct AIInsightsView: View {
    @StateObject private var aiManager = AIInsightsManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Insights")
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    
                    Text("Research-based personalized guidance")
                        .font(.system(size: 14, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await aiManager.generateInsights()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                }
                .disabled(aiManager.isLoading)
            }
            
            // Content
            if aiManager.isLoading {
                loadingView
            } else if let errorMessage = aiManager.errorMessage {
                errorView(errorMessage)
            } else if aiManager.currentInsights.isEmpty {
                emptyStateView
            } else {
                insightsList
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 12, x: 0, y: 6)
        )
        .task {
            if authManager.isAuthenticated {
                await aiManager.generateInsights()
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
            
            Text("Analyzing your patterns...")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(height: 120)
    }
    
    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            
            Text("Unable to load insights")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
            
            Text(message)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await aiManager.generateInsights()
                }
            }) {
                Text("Try Again")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.4, green: 0.5, blue: 0.6))
                    .cornerRadius(8)
            }
        }
        .frame(height: 120)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("✨")
                .font(.system(size: 40))
            
            Text("No insights yet")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
            
            Text("Add some tasks, habits, or goals to get research-based insights")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                .multilineTextAlignment(.center)
        }
        .frame(height: 120)
    }
    
    // MARK: - Insights List
    private var insightsList: some View {
        VStack(spacing: 16) {
            ForEach(aiManager.currentInsights.prefix(4)) { insight in
                EnhancedInsightCard(insight: insight)
            }
            
            if aiManager.currentInsights.count > 4 {
                Button(action: {
                    // Could expand to show more insights
                }) {
                    Text("View more insights")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                }
            }
        }
    }
}

// MARK: - Enhanced Insight Card
struct EnhancedInsightCard: View {
    let insight: AIInsight
    @Environment(\.colorScheme) private var colorScheme
    
    private var priorityColor: Color {
        switch insight.priority {
        case .high:
            return Color(red: 0.4, green: 0.5, blue: 0.6)
        case .medium:
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        case .low:
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with icon and priority
            HStack {
                Text(insight.icon)
                    .font(.system(size: 24))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(priorityColor.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    
                    Text(insight.source)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
                
                // Priority indicator
                Circle()
                    .fill(priorityColor)
                    .frame(width: 8, height: 8)
            }
            
            // Main message
            Text(insight.message)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            // Actionable step
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                
                Text(insight.actionable)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(red: 0.4, green: 0.5, blue: 0.6).opacity(0.1))
            .cornerRadius(8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color(red: 0.98, green: 0.98, blue: 0.98))
        )
    }
}

// MARK: - AI Insights Section for Dashboard
struct AIInsightsSection: View {
    @StateObject private var aiManager = AIInsightsManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack {
                Text("AI Insights")
                    .font(.system(size: 18, weight: .semibold, design: .serif))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                
                Spacer()
                
                if !aiManager.currentInsights.isEmpty {
                    Text("Updated \(timeAgoString(from: aiManager.lastUpdated))")
                        .font(.system(size: 12, design: .serif))
                        .foregroundColor(colorScheme == .dark ? Color(red: 0.6, green: 0.6, blue: 0.6) : Color(red: 0.5, green: 0.5, blue: 0.5))
                }
            }
            
            // Top Insight
            if let topInsight = aiManager.currentInsights.first {
                EnhancedTopInsightCard(insight: topInsight)
            } else if aiManager.isLoading {
                loadingView
            } else if aiManager.errorMessage != nil {
                errorView
            } else {
                emptyStateView
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? Color(red: 0.18, green: 0.18, blue: 0.18) : .white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08), radius: 8, x: 0, y: 4)
        )
    }
    
    private var loadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
            
            Text("Analyzing your patterns...")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(height: 60)
    }
    
    private var errorView: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 16))
                .foregroundColor(.orange)
            
            Text("Unable to load insights")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(height: 60)
    }
    
    private var emptyStateView: some View {
        HStack(spacing: 12) {
            Text("✨")
                .font(.system(size: 24))
            
            Text("Add some activities to get research-based insights")
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
        }
        .frame(height: 60)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Enhanced Top Insight Card
struct EnhancedTopInsightCard: View {
    let insight: AIInsight
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(insight.icon)
                    .font(.system(size: 28))
                    .frame(width: 45, height: 45)
                    .background(
                        Circle()
                            .fill(Color(red: 0.4, green: 0.5, blue: 0.6).opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.title)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.18, green: 0.18, blue: 0.18))
                    
                    Text(insight.source)
                        .font(.system(size: 11, design: .serif))
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                Spacer()
            }
            
            // Message
            Text(insight.message)
                .font(.system(size: 14, design: .serif))
                .foregroundColor(colorScheme == .dark ? Color(red: 0.7, green: 0.7, blue: 0.7) : Color(red: 0.4, green: 0.4, blue: 0.4))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            // Actionable step
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 11))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                
                Text(insight.actionable)
                    .font(.system(size: 12, weight: .medium, design: .serif))
                    .foregroundColor(Color(red: 0.4, green: 0.5, blue: 0.6))
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(red: 0.4, green: 0.5, blue: 0.6).opacity(0.1))
            .cornerRadius(6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(red: 0.22, green: 0.22, blue: 0.22) : Color(red: 0.98, green: 0.98, blue: 0.98))
        )
    }
} 