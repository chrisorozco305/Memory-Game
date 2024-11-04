import SwiftUI

// Model for each card in the game
struct Card: Identifiable {
    let id = UUID()
    let symbol: String
    var isFaceUp: Bool = false
    var isMatched: Bool = false
}

// Main game view
struct ContentView: View {
    @State private var cards: [Card] = []
    @State private var firstCardIndex: Int? = nil
    @State private var numberOfPairs: Int = 4  // Default number of pairs
    @State private var showPairsPicker: Bool = false

    var body: some View {
        VStack {
            // Game Grid
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                    ForEach(cards.indices, id: \.self) { index in
                        // Only display the card if it's not matched
                        if !cards[index].isMatched {
                            CardView(card: cards[index])
                                .onTapGesture {
                                    handleCardTap(at: index)
                                }
                        }
                    }
                }
            }
            .padding()

            // Reset Button
            Button("New Game") {
                resetGame()
            }
            .padding()

            // Number of Pairs Picker
            Picker("Number of Pairs", selection: $numberOfPairs) {
                ForEach(2..<10) { pairs in
                    Text("\(pairs) Pairs").tag(pairs)
                }
            }
            .onChange(of: numberOfPairs) { _ in
                resetGame()
            }
            .padding()
        }
        .onAppear {
            resetGame()
        }
    }
    
    // Handle the card tap logic
    func handleCardTap(at index: Int) {
        // Ignore taps on cards that are already face-up or matched
        guard !cards[index].isFaceUp, !cards[index].isMatched else { return }

        if let firstIndex = firstCardIndex {
            cards[index].isFaceUp = true
            if cards[firstIndex].symbol == cards[index].symbol {
                cards[firstIndex].isMatched = true
                cards[index].isMatched = true
            } else {
                // Temporarily flip the cards back down after a short delay if they don’t match
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cards[firstIndex].isFaceUp = false
                    cards[index].isFaceUp = false
                }
            }
            firstCardIndex = nil  // Reset the first card index
        } else {
            firstCardIndex = index  // Mark the first card index
            cards[index].isFaceUp = true
        }
    }

    // Reset and shuffle cards for a new game
    func resetGame() {
        let symbols = (1...(numberOfPairs)).map { "\($0)" }
        let pairs = symbols + symbols  // Duplicate each symbol to form pairs
        cards = pairs.shuffled().map { Card(symbol: $0) }
        firstCardIndex = nil
    }
}

// View for each card
struct CardView: View {
    let card: Card

    var body: some View {
        ZStack {
            if card.isFaceUp {
                Text(card.symbol)
                    .font(.largeTitle)
                    .frame(width: 60, height: 90)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 3)
            } else if !card.isMatched {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 60, height: 90)
                    .cornerRadius(8)
            }
        }
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
