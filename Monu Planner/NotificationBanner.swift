import SwiftUI

struct NotificationBanner: View {
    let title: String
    let message: String
    let type: BannerType
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var offset: CGFloat = -200
    
    enum BannerType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .warning: return .orange
            case .error: return .red
            case .info: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(type.color)
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Dismiss button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offset = -200
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                offset = 0
            }
        }
    }
}

class NotificationBannerManager: ObservableObject {
    static let shared = NotificationBannerManager()
    
    @Published var currentBanner: NotificationBannerData?
    
    private init() {}
    
    func showBanner(title: String, message: String, type: NotificationBanner.BannerType) {
        currentBanner = NotificationBannerData(
            title: title,
            message: message,
            type: type
        )
        
        // Auto-dismiss after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.dismissBanner()
        }
    }
    
    func dismissBanner() {
        currentBanner = nil
    }
}

struct NotificationBannerData: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationBanner.BannerType
}

struct NotificationBannerContainer: View {
    @ObservedObject var bannerManager = NotificationBannerManager.shared
    
    var body: some View {
        ZStack {
            if let banner = bannerManager.currentBanner {
                VStack {
                    NotificationBanner(
                        title: banner.title,
                        message: banner.message,
                        type: banner.type
                    ) {
                        bannerManager.dismissBanner()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bannerManager.currentBanner != nil)
            }
        }
    }
}

#Preview {
    VStack {
        NotificationBanner(
            title: "Success!",
            message: "Your task has been completed successfully.",
            type: .success
        ) {
            print("Banner dismissed")
        }
        .padding()
        
        Spacer()
    }
    .background(Color.gray.opacity(0.1))
} 