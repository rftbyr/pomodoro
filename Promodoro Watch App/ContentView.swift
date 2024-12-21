//
//  ContentView.swift
//  Promodoro Watch App
//
//  Created by Rıfat on 20.12.2024.
//

import SwiftUI
import WatchKit

struct ContentView: View {
    // Varsayılan değerler
    private let defaultWorkTime = 25 * 60  // 25 dakika
    private let defaultBreakTime = 5 * 60  // 5 dakika
    
    @State private var timeRemaining = 25 * 60
    @State private var timer: Timer?
    @State private var isActive = false
    @State private var isPomodoroMode = true
    @AppStorage("completedPomodoros") private var completedPomodoros = 0
    @State private var initialTime: Double = 25.0 * 60.0
    
    // Ekran boyutlarını al
    private var screenWidth: CGFloat {
        WKInterfaceDevice.current().screenBounds.width
    }
    private var screenHeight: CGFloat {
        WKInterfaceDevice.current().screenBounds.height
    }
    private var progress: Double {
        if !isActive { return 0.0 }
        
        if isPomodoroMode {
            return 1.0 - (Double(timeRemaining) / initialTime)
        } else {
            return 1.0 - (Double(timeRemaining) / Double(defaultBreakTime))
        }
    }
    
    var body: some View {
        VStack {
            // Üst bilgi alanı
            HStack {
                Text("\(completedPomodoros)")
                    .font(.system(size: screenHeight * 0.08, weight: .medium))
                    .foregroundColor(.cyan)
                Text("Pomodoro")
                    .font(.system(size: screenHeight * 0.08, weight: .regular))
                    .foregroundColor(.gray.opacity(0.8))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            // Timer alanı
            ZStack {
                CircularTimerView(
                    progress: progress,
                    timeRemaining: timeRemaining,
                    isPomodoroMode: isPomodoroMode
                )
                .frame(width: screenWidth - 50, height: screenHeight - 80)
                .contentShape(Circle())
                .onTapGesture {
                    if isActive {
                        stopTimer()
                    } else {
                        startTimer()
                    }
                }
            }
            // Kontrol butonları - daha kompakt
            HStack{
                Button(action: decreaseTime) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: screenHeight * 0.1))
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
                .disabled(isActive)
                Spacer()
                Button(action: resetTimer) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: screenHeight * 0.1))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: increaseTime) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: screenHeight * 0.1))
                        .foregroundStyle(.cyan)
                }
                .buttonStyle(.plain)
                .disabled(isActive)
            }
            .padding(.horizontal, 20)
            .padding(.bottom)
        }
       
    }
    
    // fonksiyonlar
    
    private func startTimer() {
        isActive = true
        initialTime = Double(timeRemaining)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeCycle()
            }
        }
    }
    
    private func stopTimer() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        if isPomodoroMode {
            timeRemaining = defaultWorkTime
            initialTime = Double(defaultWorkTime)
        } else {
            timeRemaining = defaultBreakTime
            initialTime = Double(defaultBreakTime)
        }
    }
    
    private func completeCycle() {
        stopTimer()
        if isPomodoroMode {
            completedPomodoros += 1
            timeRemaining = defaultBreakTime
            initialTime = Double(defaultBreakTime)
            isPomodoroMode.toggle()
        } else {
            timeRemaining = defaultWorkTime
            initialTime = Double(defaultWorkTime)
            isPomodoroMode.toggle()
        }
        WKInterfaceDevice.current().play(.notification)
    }
    
    private func decreaseTime() {
        guard !isActive else { return }
        let currentMinutes = timeRemaining / 60
        if currentMinutes > 1 {
            timeRemaining = (currentMinutes - 1) * 60
            initialTime = Double(timeRemaining)
        }
    }
    
    private func increaseTime() {
        guard !isActive else { return }
        let currentMinutes = timeRemaining / 60
        if currentMinutes < 60 {
            timeRemaining = (currentMinutes + 1) * 60
            initialTime = Double(timeRemaining)
        }
    }
}

struct WatchPreview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
