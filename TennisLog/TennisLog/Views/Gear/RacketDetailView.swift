import SwiftUI
import SwiftData

struct RacketDetailView: View {
    @Bindable var racket: Racket
    @Environment(\.modelContext) private var context
    @State private var showRestrungSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GearItemRow(
                    name: racket.name,
                    detail: "\(racket.stringName)  ·  \(racket.tensionLbs) lbs",
                    fraction: racket.warnFraction,
                    barLabel: racket.hoursDetail,
                    badgeLabel: racket.statusLabel,
                    isWarning: racket.warningSoon)
                .padding(.horizontal, -16) // cancel GearView's padding

                detailCard

                if racket.needsRestring {
                    Button { showRestrungSheet = true } label: {
                        Label("Log Restring", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.tBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.tAccent)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.tBg.ignoresSafeArea())
        .navigationTitle(racket.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRestrungSheet) { RestrungSheet(racket: racket) }
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            InfoRow(label: "String",        value: racket.stringName)
            InfoRow(label: "Tension",       value: "\(racket.tensionLbs) lbs")
            InfoRow(label: "Last restring", value: racket.lastRestrungDate.relativeVerbose)
            InfoRow(label: "Hours played",  value: racket.hoursDetail)
            InfoRow(label: "Month limit",   value: racket.monthsDetail)
        }
        .padding(16)
        .tennisCard()
    }
}

struct ShoeDetailView: View {
    @Bindable var shoe: Shoe
    @Environment(\.modelContext) private var context

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                GearItemRow(
                    name: shoe.name,
                    detail: "\(shoe.surface.rawValue) court",
                    fraction: shoe.wornFraction,
                    barLabel: shoe.wornDetail,
                    badgeLabel: shoe.statusLabel,
                    isWarning: shoe.warningSoon)
                .padding(.horizontal, -16)

                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(label: "Brand",       value: shoe.brand)
                    InfoRow(label: "Surface",     value: shoe.surface.rawValue)
                    InfoRow(label: "Added",       value: shoe.dateAdded.relativeVerbose)
                    InfoRow(label: "Hours worn",  value: shoe.wornDetail)
                }
                .padding(16)
                .tennisCard()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.tBg.ignoresSafeArea())
        .navigationTitle(shoe.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Restring sheet

private struct RestrungSheet: View {
    @Bindable var racket: Racket
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var newString  = ""
    @State private var tensionLbs = 55
    @State private var restrungDate = Date()

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                FormFieldSimple(label: "New string", value: $newString,
                                placeholder: racket.stringName)
                HStack {
                    Text("Tension").font(.system(size: 13)).foregroundStyle(Color.tText2)
                    Spacer()
                    Stepper("\(tensionLbs) lbs", value: $tensionLbs, in: 40...80)
                        .foregroundStyle(.white)
                }
                .padding(14)
                .background(Color.tCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                DatePicker("Date", selection: $restrungDate, displayedComponents: .date)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(Color.tCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Spacer()

                Button { save() } label: {
                    Text("Save Restring")
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.tBg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.tAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(20)
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("Log Restring")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color.tText2)
                }
            }
            .onAppear { tensionLbs = racket.tensionLbs }
        }
    }

    private func save() {
        if !newString.isEmpty { racket.stringName = newString }
        racket.tensionLbs = tensionLbs
        racket.lastRestrungDate = restrungDate
        racket.hoursPlayedSinceRestring = 0
        try? context.save()
        dismiss()
    }
}

private struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 12)).foregroundStyle(Color.tText2)
            Spacer()
            Text(value).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
        }
    }
}

private struct FormFieldSimple: View {
    let label: String
    @Binding var value: String
    let placeholder: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).capsLabel()
            TextField(placeholder, text: $value)
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.tCard)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
