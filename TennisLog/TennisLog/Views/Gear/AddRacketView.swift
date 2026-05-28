import SwiftUI
import SwiftData

struct AddRacketView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    @State private var name        = ""
    @State private var brand       = ""
    @State private var stringName  = ""
    @State private var tensionLbs  = 55
    @State private var hourLimit   = 25.0
    @State private var monthLimit  = 3
    @State private var restrungDate = Date()

    var canSave: Bool { !name.isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    formSection("Racket") {
                        FormField(label: "Name",  value: $name,  placeholder: "e.g. Babolat Pure Drive")
                        FormField(label: "Brand", value: $brand, placeholder: "e.g. Babolat")
                    }
                    formSection("Strings") {
                        FormField(label: "String", value: $stringName, placeholder: "e.g. RPM Blast 16")
                        HStack {
                            Text("Tension").font(.system(size: 13)).foregroundStyle(Color.tText2)
                            Spacer()
                            Stepper("\(tensionLbs) lbs", value: $tensionLbs, in: 40...80)
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .background(Color.tCard2)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        DatePicker("Last restrung", selection: $restrungDate, displayedComponents: .date)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Color.tCard2)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    formSection("Restring Reminder (whichever comes first)") {
                        HStack {
                            Text("Hour limit").font(.system(size: 13)).foregroundStyle(Color.tText2)
                            Spacer()
                            Stepper("\(Int(hourLimit))h", value: $hourLimit, in: 5...60, step: 5)
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .background(Color.tCard2)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        HStack {
                            Text("Month limit").font(.system(size: 13)).foregroundStyle(Color.tText2)
                            Spacer()
                            Stepper("\(monthLimit) mo", value: $monthLimit, in: 1...12)
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .background(Color.tCard2)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        save()
                    } label: {
                        Text("Add Racket")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(Color.tBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(canSave ? Color.tAccent : Color.tCard2)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(!canSave)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("Add Racket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color.tText2)
                }
            }
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).capsLabel().padding(.top, 8)
            content()
        }
    }

    private func save() {
        let racket = Racket(
            name: name, brand: brand, stringName: stringName,
            tensionLbs: tensionLbs, lastRestrungDate: restrungDate,
            hourLimit: hourLimit, monthLimit: monthLimit)
        context.insert(racket)
        NotificationService.shared.scheduleGearAlert(for: racket)
        try? context.save()
        dismiss()
    }
}

struct AddShoeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss)      private var dismiss

    @State private var name      = ""
    @State private var brand     = ""
    @State private var surface   = Surface.hard
    @State private var hourLimit = 60.0
    @State private var dateAdded = Date()

    var canSave: Bool { !name.isEmpty }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    formSection("Shoe") {
                        FormField(label: "Name",  value: $name,  placeholder: "e.g. Asics Gel-Resolution 9")
                        FormField(label: "Brand", value: $brand, placeholder: "e.g. Asics")
                    }
                    formSection("Details") {
                        Picker("Surface", selection: $surface) {
                            ForEach(Surface.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        DatePicker("Date added", selection: $dateAdded, displayedComponents: .date)
                            .foregroundStyle(.white)
                            .padding(14)
                            .background(Color.tCard2)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    formSection("Replacement Reminder") {
                        HStack {
                            Text("Hour limit").font(.system(size: 13)).foregroundStyle(Color.tText2)
                            Spacer()
                            Stepper("\(Int(hourLimit))h", value: $hourLimit, in: 20...100, step: 5)
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .background(Color.tCard2)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        save()
                    } label: {
                        Text("Add Shoes")
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(Color.tBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(canSave ? Color.tAccent : Color.tCard2)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .disabled(!canSave)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color.tBg.ignoresSafeArea())
            .navigationTitle("Add Shoes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(Color.tText2)
                }
            }
        }
    }

    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).capsLabel().padding(.top, 8)
            content()
        }
    }

    private func save() {
        let shoe = Shoe(name: name, brand: brand, surface: surface,
                        dateAdded: dateAdded, hourLimit: hourLimit)
        context.insert(shoe)
        NotificationService.shared.scheduleGearAlert(for: shoe)
        try? context.save()
        dismiss()
    }
}

private struct FormField: View {
    let label: String
    @Binding var value: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.tText3)
                .tracking(1)
                .textCase(.uppercase)
            TextField(placeholder, text: $value)
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.tCard2)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
