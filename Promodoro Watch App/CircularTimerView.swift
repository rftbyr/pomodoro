//
//  CircularTimerView.swift
//  Promodoro
//
//  Created by Rıfat on 20.12.2024.
//

import SwiftUI
import WatchKit

struct CircularTimerView: View {
    let progress: Double
    let timeRemaining: Int
    let isPomodoroMode: Bool
    
    private var screenHeight: CGFloat {
        WKInterfaceDevice.current().screenBounds.height
    }
    
    var body: some View {
        ZStack {
            // Arka plan çemberi
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 10)
            
            // İlerleme çemberi
            Circle()
                .trim(from: 0, to: progress)
                .stroke(isPomodoroMode ? Color.red : Color.green, lineWidth: 10)
                .rotationEffect(.degrees(-90))
            
            VStack {
                // Zaman göstergesi
                Text(timeString(from: timeRemaining))
                    .font(.system(size: screenHeight * 0.15, weight: .bold))
                    .foregroundStyle(.cyan)
                
                // Mod göstergesi
                Text(isPomodoroMode ? "Work" : "Break")
                    .font(.system(size: screenHeight * 0.07))
                    .foregroundColor(isPomodoroMode ? .red : .green)
            }
        }
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}


#Preview {
    ContentView()
}
