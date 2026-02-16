import SwiftUI
import Combine

enum AnswerResult {
    case correct
    case wrong
}

struct ContentView: View {
    @State private var number = Int.random(in: 10...99)
    @State private var awaitingAnswer = true
    @State private var result: AnswerResult? = nil

    @State private var timeLeft = 5

    @State private var batchAttempts = 0
    @State private var batchCorrect = 0
    @State private var batchWrong = 0

    @State private var showSummary = false
    @State private var summaryCorrect = 0
    @State private var summaryWrong = 0

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            LinearGradient(colors: [.white, Color.teal.opacity(0.08)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Attempt \(min(batchAttempts + 1, 10)) / 10")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray)

                Text("\(timeLeft)s")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(timeLeft <= 2 ? .red : .teal)

                Text("\(number)")
                    .font(.system(size: 72, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(.teal)
                    .padding(.vertical, 10)

                VStack(spacing: 14) {
                    Button {
                        answer(userSaysPrime: true)
                    } label: {
                        Text("Prime")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .italic()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.teal.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!awaitingAnswer || showSummary)

                    Button {
                        answer(userSaysPrime: false)
                    } label: {
                        Text("Non-Prime")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .italic()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.teal.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(!awaitingAnswer || showSummary)
                }
                .padding(.horizontal, 28)

                Spacer()

                if let result {
                    Image(systemName: result == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 110, weight: .heavy))
                        .foregroundStyle(result == .correct ? .green : .red)
                        .padding(.bottom, 10)
                } else {
                    Spacer().frame(height: 140)
                }

                Spacer()
            }
            .padding(.top, 30)
        }
        .onAppear {
            startRound()
        }
        .onReceive(timer) { _ in
            if showSummary { return }
            if !awaitingAnswer { return }

            if timeLeft > 0 {
                timeLeft -= 1
            }

            if timeLeft == 0 {
                timeout()
            }
        }
        .alert("Summary (last 10 attempts)", isPresented: $showSummary) {
            Button("OK") {
                batchAttempts = 0
                batchCorrect = 0
                batchWrong = 0
                showSummary = false
                startRound()
            }
        } message: {
            Text("Correct: \(summaryCorrect)\nWrong: \(summaryWrong)")
        }
    }

    private func startRound() {
        number = Int.random(in: 10...99)
        awaitingAnswer = true
        result = nil
        timeLeft = 5
    }

    private func moveNextAfterShortDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            if showSummary { return }
            startRound()
        }
    }

    private func answer(userSaysPrime: Bool) {
        if showSummary { return }
        if !awaitingAnswer { return }

        let correct = (userSaysPrime == isPrime(number))
        result = correct ? .correct : .wrong
        awaitingAnswer = false
        record(isCorrect: correct)

        if !showSummary {
            moveNextAfterShortDelay()
        }
    }

    private func timeout() {
        if showSummary { return }
        if !awaitingAnswer { return }

        result = .wrong
        awaitingAnswer = false
        record(isCorrect: false)

        if !showSummary {
            moveNextAfterShortDelay()
        }
    }

    private func record(isCorrect: Bool) {
        batchAttempts += 1

        if isCorrect {
            batchCorrect += 1
        } else {
            batchWrong += 1
        }

        if batchAttempts == 10 {
            summaryCorrect = batchCorrect
            summaryWrong = batchWrong
            showSummary = true
            awaitingAnswer = false
        }
    }

    private func isPrime(_ n: Int) -> Bool {
        if n < 2 { return false }
        if n == 2 { return true }
        if n % 2 == 0 { return false }

        var i = 3
        while i * i <= n {
            if n % i == 0 { return false }
            i += 2
        }
        return true
    }
}

#Preview {
    ContentView()
}

