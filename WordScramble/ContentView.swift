//
//  ContentView.swift
//  WordScramble
//
//  Created by Chuck Condron on 6/5/23.
//

import SwiftUI

struct ContentView: View {
  
  enum FocusField {
    case guessField
  }
  
  @State private var usedWords = [String]()
  @State private var rootWord = ""
  @State private var newWord = ""
  @State private var score = 0
  
  @State private var errorTitle = ""
  @State private var errorMessage = ""
  @State private var showingError = false
  
  var body: some View {
    NavigationView {
      List {
        Section("Enter your word") {
          TextField("Enter at least 3 letters", text: $newWord)
            .textInputAutocapitalization(.never)
        }
        
        Section("Words used so far...") {
          ForEach(usedWords, id: \.self) { word in
            HStack {
              Image(systemName: "\(word.count).circle")
                .foregroundColor(Color.blue)
              Text(word)
              Text(" - Word Score is: \(word.count + 1)")
                .foregroundColor(.blue)
            }
          }
        }
      }
      .navigationTitle(rootWord)
      .onSubmit(addNewWord)
      .onAppear(perform: startGame)
      .alert(errorTitle, isPresented: $showingError) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(errorMessage)
      }
      .toolbar {
        Button("Start New Game", action: startGame)
      }
      .safeAreaInset(edge: .bottom) {
        VStack {
          HStack {
            Text("Score: ")
              .font(.title)
              .fontWeight(.bold)
              .foregroundColor(.white)
            Text(String(score))
              .foregroundColor(Color.white)
              .font(.largeTitle)
              .fontWeight(.bold)
          }
          Text("1 point for each word, 1 point per letter")
            .font(.title3)
            .italic()
            .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.blue)
        
      }
    }
  }
  
  func addNewWord () {
    // lowercase and trim the word, to make sure we don't add duplicate words with case differences
    let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    
    // exit if the remaining string is empty or less than 3
    guard answer.count > 3 else {
      wordError(title: "Word too short", message: "Word must be greater than 3 characters...")
      return }
    
    guard answer != rootWord else {
      wordError(title: "Word same as rootword", message: "Word can't be the same as original word")
      return
    }
    
    guard isOriginal(word: answer) else {
      wordError(title: "Word used already", message: "Be more original")
      return
    }
    
    guard isPossible(word: answer) else {
      wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
      return
    }
    
    guard isReal(word: answer) else {
      wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
      return
    }
    
    
    withAnimation{
      usedWords.insert(answer, at: 0)
      score += (answer.count + usedWords.count)
    }
    newWord = ""
  }
  
  func startGame() {
    score = 0
    usedWords.removeAll()
    newWord = ""
    // 1. Find the URL for start.txt in our app bundle
    if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
      // 2. Load start.txt into a string
      if let startWords = try? String(contentsOf: startWordsURL) {
        // 3. Split the string up into an array of strings, splitting on line breaks
        let allWords = startWords.components(separatedBy: "\n")
        
        // 4. Pick one random word, or use "silkworm" as a sensible default
        rootWord = allWords.randomElement() ?? "silkworm"
        
        // If we are here everything has worked, so we can exit
        return
      }
    }
    
    // If were are *here* then there was a problem – trigger a crash and report the error
    fatalError("Could not load start.txt from bundle.")
  }
  
  func isOriginal(word: String) -> Bool {
    !usedWords.contains(word)
  }
  
  func isPossible(word: String) -> Bool {
    var tempWord = rootWord
    
    for letter in word {
      if let pos = tempWord.firstIndex(of: letter) {
        tempWord.remove(at: pos)
      } else {
        return false
      }
    }
    
    return true
  }
  
  func isReal(word: String) -> Bool {
    let checker = UITextChecker()
    let range = NSRange(location: 0, length: word.utf16.count)
    let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
    
    return misspelledRange.location == NSNotFound
  }
  
  func wordError(title: String, message: String) {
    errorTitle = title
    errorMessage = message
    showingError = true
  }
  
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
