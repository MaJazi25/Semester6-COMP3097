import SwiftUI

enum AnswerResult {
    case correct
    case wrong
}

struct ContentView: View {
    @State private var number = Int.random(in: 10...99)
    @State private var awaitingAnswer = true
    @State private var result: AnswerResult? = nil

    @State private var roundIndex = 0

    @State private var batchAttempts = 0
    @State private var batchCorrect = 0
    @State private var batchWrong = 0

    @State private var showSummary = false
    @State private var summaryCorrect = 0
    @State private var summaryWrong = 0

    @State private var tickID = UUID()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Color.white.ignoresSafeArea()

            VStack(spacing: 26) {
                Spacer()

                Text("\(number)")
                    .font(.system(size: 72, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(.teal)

                VStack(spacing: 18) {
                    Button {
                        answer(userSaysPrime: true)
                    } label: {
                        Text("Prime")
                            .font(.system(size: 34, weight: .regular, design: .serif))
                            .italic()
                            .foregroundStyle(.teal)
                    }
                    .buttonStyle(.plain)

                    Button {
                        answer(userSaysPrime: false)
                    } label: {
                        Text("non Prime")
                            .font(.system(size: 34, weight: .regular, design: .serif))
                            .italic()
                            .foregroundStyle(.teal)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                if let result {
                    Image(systemName: result == .correct ? "checkmark" : "xmark")
                        .font(.system(size: 120, weight: .heavy))
                        .foregroundStyle(result == .correct ? .green : .red)
                        .padding(.bottom, 40)
                } else {
                    Spacer().frame(height: 160)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("\(roundIndex)")
                .font(.system(size: 14))
                .foregroundStyle(.red)
                .padding(.leading, 12)
                .padding(.bottom, 10)
        }
        .onAppear {
            startFirstRound()
        }
        .task(id: tickID) {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await MainActor.run {
                    if showSummary { return }

                    if awaitingAnswer {
                        record(isCorrect: false)
                    }

                    if showSummary { return }
                    advanceRound()
                }
            }
        }
        .alert("Summary (last 10 attempts)", isPresented: $showSummary) {
            Button("OK") {
                batchAttempts = 0
                batchCorrect = 0
                batchWrong = 0
                showSummary = false
                advanceRound()
                tickID = UUID()
            }
        } message: {
            Text("Correct: \(summaryCorrect)\nWrong: \(summaryWrong)")
        }
    }

    private func startFirstRound() {
        number = Int.random(in: 10...99)
        awaitingAnswer = true
        result = nil
        roundIndex = 0
        batchAttempts = 0
        batchCorrect = 0
        batchWrong = 0
        showSummary = false
    }

    private func advanceRound() {
        roundIndex += 1
        number = Int.random(in: 10...99)
        awaitingAnswer = true
        result = nil
    }

    private func answer(userSaysPrime: Bool) {
        if showSummary { return }
        if !awaitingAnswer { return }

        let correct = (userSaysPrime == isPrime(number))
        result = correct ? .correct : .wrong
        awaitingAnswer = false
        record(isCorrect: correct)
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


