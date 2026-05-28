import SwiftUI
import SwiftData

/// Shown after a session completes — quick quality rating + optional notes.
struct PostSessionRatingView: View {
    @Bindable var session: Session
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    @State private var rating: Int = 3
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("How did it feel?")
                    .font(.system(size: 22, weight: .black))
                    .foregroundStyle(.white)

                // Star picker
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { i in
                        Button {
                            rating = i
                        } label: {
                            Text(i <= rating ? "★" : "☆")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.tAccent)
                                .scaleEffect(i <= rating ? 1.1 : 1.0)
                                .animation(.spring(duration: 0.2), value: rating)
                        }
                    }
                }

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes (optional)")
                        .capsLabel()
                    TextField("How did you play?", text: $notes, axis: .vertical)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.tCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .lineLimit(3...6)
                }

                Button {
                    session.qualityRating = rating
                    session.notes = notes
                    try? context.save()
                    dismiss()
                } label: {
                    Text("Save")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.tBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Spacer()
            }
            .padding(24)
            .background(Color.tBg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") { dismiss() }
                        .foregroundStyle(Color.tText2)
                }
            }
        }
    }
}
