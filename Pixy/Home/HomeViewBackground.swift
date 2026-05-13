import SwiftUI

struct HomeViewBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.95, blue: 0.90),
                    Color(red: 0.93, green: 0.87, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Circle()
                .fill(.orange.opacity(0.18))
                .frame(width: 320)
                .blur(radius: 30)
                .offset(x: -180, y: -260)
            
            Circle()
                .fill(.red.opacity(0.12))
                .frame(width: 280)
                .blur(radius: 40)
                .offset(x: 240, y: 320)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    HomeViewBackground()
}
