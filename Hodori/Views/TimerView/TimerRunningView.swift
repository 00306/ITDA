//
//  TimerRunningView.swift
//  Hodori
//
//  Created by Yujin Son on 2023/11/14.
//

import SwiftUI

struct TimerRunningView: View {
    
    @Binding var sec : Double
    @Binding var showTimer: Bool
    
    let date = Date()
    
    @State var timeRemaining : Int = 0
    @State private var blinkTimer: Timer?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var isClicked = false
    @State private var animate = false
    let feedback = UIImpactFeedbackGenerator(style: .soft)
    @State private var isBlinking = false
        
    private let mediumHaptic = UIImpactFeedbackGenerator(style: .medium)
    
    var hours: Int {
            return timeRemaining / 3600
        }

        var minutes: Int {
            return (timeRemaining - hours * 3600) / 60
        }

        var seconds: Int {
            return timeRemaining % 60
        }
    
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    playButton
                    cancelButton
                }
                .padding(.trailing, 20)
                VStack {
                    timerString
                }
            }
            .padding(.leading, 16) // 하이파이 참고해서 패딩값 수정 필요.
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.white)
            }
        }
        .ignoresSafeArea(edges: .top)
//        .transition(.move(edge: .top))
    }
    
    
//    func convertSecondsToTime(timeInSeconds: Int) -> String {
//        let hours = timeInSeconds / 3600
//        let minutes = (timeInSeconds - hours*3600) / 60
//        let seconds = timeInSeconds % 60
//        return String(format: "%02i:%02i:%02i", hours,minutes,seconds)
//    }
    
    
    func calcRemain() {
        let calendar = Calendar.current // 현재 시간 저장
        let targetTime : Date = calendar.date(byAdding: .second, value: Int($sec.wrappedValue), to: date, wrappingComponents: false) ?? Date() // 설정한 초들을 date 형식으로 바꿔서 calendar에 저장
        self.timeRemaining =  Int(targetTime.timeIntervalSince(date)) // timeRemaining에 시간 값을 바로 넣게 변형
        
    }
    
    func stopTimer() {
        
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    private func startStopBlinking() {
        if isClicked {
            blinkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    self.isBlinking.toggle()
                }
            }
        } else {
            stopBlinking()
        }
    }
    
    private func stopBlinking() {
        blinkTimer?.invalidate()
        blinkTimer = nil
        withAnimation {
            self.isBlinking = false
        }
    }
    // 타이머 초기화 함수
    private func resetTimer() {
        timeRemaining = 0
        isClicked = false
        stopBlinking()
    }
    
    private var playButton: some View {
        Button {
            mediumHaptic.impactOccurred()
            withAnimation(.bouncy){
                isClicked.toggle()
                if isClicked {
                    stopTimer()
                    startStopBlinking()
                } else {
                    startTimer()
                    stopBlinking()
                }
            }
        } label: {
            HStack {
                Image(systemName: isClicked ? "play.fill" : "pause.fill")
                    .resizable()
                    .frame(width: 14, height: 19)
                    .font(Font.largeTitle.weight(Font.Weight.thin))
                    .foregroundColor(.gray5)
                    .padding()
                    .background(Circle().fill(Color.gray9))
                    .frame(width: 40, height: 40)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 4)
        
    }
    
    private var cancelButton: some View {
        Button {
            mediumHaptic.impactOccurred()
            withAnimation(.bouncy){
                self.stopTimer()
                showTimer = false
                sec = 0.0
            }
        } label: {
            HStack {
                Image(systemName: "xmark")
                    .resizable()
                    .font(Font.caption.bold())
                    .frame(width: 17, height: 17)
                    .foregroundColor(.gray5)
                    .padding()
                    .background(Circle().fill(Color.gray9))
                    .frame(width: 40, height: 40)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 30)
    }
    
    private var timerString: some View {
        
        ZStack {
            Rectangle()
                .fill(.white)
                .frame(width: 160, height: 56)
                .alignmentGuide(.top) { $0[VerticalAlignment.center] }
//            Text(convertSecondsToTime(timeInSeconds:timeRemaining))
            HStack(spacing: 0) {
               
                    Text(String(format: "%02d", hours))
                        .font(Font.system(size: 40).monospacedDigit())
                        .foregroundColor(isBlinking ? .clear : .black)
//                        .frame(width: 50, height: 50)
                
                    Text(":")
                        .font(Font.system(size: 40).monospacedDigit())
                        .foregroundColor(isBlinking ? .clear : .black)
                        .padding(.horizontal, 1)
                        .padding(.bottom, 5)
                
                    Text(String(format: "%02d", minutes))
                        .font(Font.system(size: 40).monospacedDigit())
                        .foregroundColor(isBlinking ? .clear : .black)
//                        .frame(width: 50, height: 50)

                
                    Text(":")
                        .font(Font.system(size: 40).monospacedDigit())
                        .foregroundColor(isBlinking ? .clear : .black)
                        .padding(.horizontal, 1)
                        .padding(.bottom, 5)

//                    Spacer()
              
                    Text(String(format: "%02d", seconds))
                        .font(Font.system(size: 40).monospacedDigit())
                        .foregroundColor(isBlinking ? .clear : .black)
//                        .frame(width: 50, height: 50)
                
            }
//                .font(.system(size: 40))
//                .foregroundColor(isBlinking ? .clear : .black)
                .onAppear {
                    startStopBlinking()
                }
                .onReceive(timer) { _ in
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                        if timeRemaining == 0 {
                            SoundManager.instance.playSound()
                            stopTimer()
                            feedback.impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) { //  사운드 fix되면 사운드 길이 확인해서 지속시간 상수로 입력하기.
                                showTimer = false
                            } //    10초 지난 후에 showTimer false.
                        }
                    }
                }
                .onAppear {
                    calcRemain()
                }
        }
//        .padding(.vertical, 12)
//            .padding(.trailing, 20)
    }
}



#Preview {
    TimerRunningView(sec: Binding.constant(0), showTimer : Binding.constant(false))
}



    

