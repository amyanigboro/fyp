//
//  PastFastsView.swift
//  FastHabbit
//
//  Created by Amy  on 14/03/2025.
//


import SwiftUI

struct PastFasts: View {
    @State private var fasts: [Fast] = []
    @State private var currentPage = 0
    @State private var selectedFast: Fast?
    @StateObject private var store = FastStore()
    @State private var isEditing = false
    @State private var addingPastFast = false
    @State private var draftFast: Fast = Fast(id: "ABCDE", startDate: Date.now, endDate: Date.now, isComplete: true, flowerEarned: "Blue", duration: 1.2, sethours: 16)

    //for the grid
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 4)
    private let rows = 7
    private var itemsPerPage: Int { columns.count * rows }
    private var pageCount: Int {
        max(1, Int((fasts.count + itemsPerPage - 1) / itemsPerPage))
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .ignoresSafeArea()
            Image("Gardenbg")
                .resizable()
                .frame(width: 400, height: 700)
                .padding(.bottom, 50)
            
            VStack {
                // 7x4 grid
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(0..<itemsPerPage, id: \.self) { slot in
                        let index = currentPage * itemsPerPage + slot
                        
                        if index < fasts.count {
                            let fast = fasts[index]
                            Image(stageImageName(for: fast))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .onTapGesture {
                                    selectedFast = fast
                                }
                        }
                        else {
                            Image("dirt")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                        }
                        
                    } //end of for loop
                } //end of grif
                .onAppear {
                    store.startListening()
                }
                .onDisappear {
                    store.stopListening()
                }
                .padding(.horizontal, 40.0)
                .padding(.bottom, 0)
                
                HStack {
                    Button() {
                        currentPage = max(0, currentPage - 1)
                    } label: {
                        Image("Previous leaf button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                    }
                    .onTapGesture(){}
                    .disabled(currentPage == 0)

                    Text("Page \(currentPage + 1) of \(pageCount)")

                    Button() {
                        currentPage = min(pageCount - 1, currentPage + 1)
                    } label: {
                        Image("Next leaf button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 100)
                    }
                    .onTapGesture(){}
                    .disabled(currentPage == pageCount - 1)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 0)
                .offset(y: -30)

            } // end of vstack
            .padding(.horizontal, 56)
            .offset(y:70)
            
            
            Button {
                // reset the draft
                draftFast = Fast(
                    id: UUID().uuidString,
                    startDate: Date(),
                    endDate: Date(),
                    isComplete: false,
                    flowerEarned: "Retrospect",
                    duration: 0,
                    sethours: 16
                )
                addingPastFast = true
            } label: {
                Image("Add button")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            }
            .offset(x:-150, y:-340)
            .onTapGesture(){}
            .padding()
            
            if addingPastFast {
              // dim background
              Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { addingPastFast = false }

              // pop‑up card
              VStack(spacing: 16) {
                Text("Add Past Fast")
                  .font(.headline)
                DatePicker("Start", selection: $draftFast.startDate, displayedComponents: [.date, .hourAndMinute])
                  .datePickerStyle(.compact)
                DatePicker("End",   selection: $draftFast.endDate,   displayedComponents: [.date, .hourAndMinute])
                  .datePickerStyle(.compact)

                // choose set hours
                Picker("Hours", selection: $draftFast.sethours) {
                  Text("13h").tag(13.0)
                  Text("16h").tag(16.0)
                  Text("18h").tag(18.0)
                  Text("Custom…").tag(draftFast.sethours) // you could also pop another prompt here
                }
                .pickerStyle(SegmentedPickerStyle())

                HStack {
                  Button("Cancel") {
                    addingPastFast = false
                  }
                  Spacer()
                  Button("Save") {
                    draftFast.duration = draftFast.startDate.distance(to: draftFast.endDate)
                    draftFast.isComplete = draftFast.duration >= draftFast.sethours
                    FirestoreService.shared.save(draftFast) { _ in
                      loadFasts()
                      addingPastFast = false
                    }
                  }
                }
              }
              .padding()
              .frame(width: 300)
              .background(.ultraThinMaterial)
              .cornerRadius(12)
              .shadow(radius: 8)
            }
            
            
            // MARK: –– the little pop‑up card
            if let fast = selectedFast {
                // a semi‑transparent backdrop
                Color.black.opacity(0.4)
                  .ignoresSafeArea()
                  .onTapGesture { selectedFast = nil }

                // the card itself
                VStack(spacing: 16) {
                    Text("🌸 \(fast.flowerEarned)")
                        .font(.title2).bold()

                    Text("Start: \(fast.startDate.formatted(.dateTime.month().day().hour().minute()))")
                    Text("End:   \(fast.endDate  .formatted(.dateTime.month().day().hour().minute()))")
                    Text("Length: \(Int(fast.duration/3600))h \(Int((fast.duration.truncatingRemainder(dividingBy: 3600))/60))m")
                        .foregroundColor(fast.isComplete ? .green : .orange)

                    HStack {
                        Button("Edit") {
                            draftFast = fast
                            isEditing = true
                        }
                        Spacer()
                        Button("Delete") {
                          // call FirestoreService.shared.delete(fast)
                            FirestoreService.shared.delete(fast)
                            selectedFast = nil
                        }
                    }
                    
                }
                .padding(20)
                .frame(maxWidth: 300)
                .background(.ultraThinMaterial)     // or Color(.systemBackground)
                .cornerRadius(16)
                .shadow(radius: 10)
            }
            // once the user taps edit, this card pops up
            if isEditing && selectedFast != nil{
                // dims backgrounf
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                    // tapping outside cancels it
                        isEditing = false
                        selectedFast = nil
                    }

                // centered edit card
                VStack(spacing: 16) {
                    Text("Edit Fast")
                    .font(.headline)

                    DatePicker("Start", selection: $draftFast.startDate)
                    .datePickerStyle(.compact)
                    DatePicker("End",   selection: $draftFast.endDate)
                    .datePickerStyle(.compact)

                  HStack {
                    Button("Cancel") {
                      isEditing = false
                    }
                    Spacer()
                    Button("Save") {
                      // recalc duration & completeness
                        draftFast.duration   = draftFast.startDate.distance(to: draftFast.endDate)
                        draftFast.isComplete = draftFast.duration >= draftFast.sethours
                        FirestoreService.shared.save(draftFast) { _ in
                            loadFasts()
                            isEditing = false
                            selectedFast = nil
                        }
                    }
                }
            }
            .padding()
            .frame(width: 300)
            .background(.ultraThinMaterial)   // or Color(.systemBackground)
            .cornerRadius(12)
            .shadow(radius: 8)
          }
        }
        .onAppear { loadFasts() }
        .navigationTitle("Your Garden")
        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $isEditing) {
//              if let fast = selectedFast {
//                EditFastView(fast: fast) { updated in
//                  // 1. write updated back to Firestore
//                  FirestoreService.shared.save(updated) { _ in
//                    // 2. reload your list/grid
//                    loadFasts()
//                    // 3. dismiss both sheets
//                    isEditing = false
//                    selectedFast = nil
//                  }
//                }
//            }
//        }
    }
    // picks the correct image name ("Blue2", "Red5", etc.)
    private func stageImageName(for fast: Fast) -> String {
        // fraction of planned complete [0…1]
        let fraction = min(1, fast.duration / fast.sethours)
        // map into 1…5
        let stage = Int(fraction * 4) + 1
        return "\(fast.flowerEarned)\(stage)"
    }
    
    private func loadFasts() {
        FirestoreService.shared.fetchAll { loaded in
            print("🔥 fetched \(loaded.count) fasts from Firestore")
//            fasts = loaded.sorted { $0.startDate > $1.startDate }
            DispatchQueue.main.async {
                self.fasts = loaded
            }
        }
    }
}

#Preview {
    PastFasts()
}
