import SwiftUI

extension Color {
    // MARK: - TennisLog palette
    static let tAccent   = Color(hex: "C8F731")   // Ace Yellow — primary CTA, streaks
    static let tBg       = Color(hex: "070B13")   // Court Night — app background
    static let tSurface  = Color(hex: "111827")   // Surface — nav bar, sheet bg
    static let tCard     = Color(hex: "1C2638")   // Card — list rows, info cards
    static let tCard2    = Color(hex: "243048")   // Card elevated — selected states
    static let tAlert    = Color(hex: "FF6835")   // Alert Orange — gear warnings
    static let tWin      = Color(hex: "4ADE80")   // Win Green
    static let tLoss     = Color(hex: "F87171")   // Loss Red
    static let tBlue     = Color(hex: "60A5FA")   // Practice Blue
    static let tText2    = Color(hex: "8B9AB8")   // Secondary text
    static let tText3    = Color(hex: "3D4F6E")   // Dim text / labels

    // MARK: - Semantic aliases
    static let tPrimary     = tAccent
    static let tDestructive = tLoss
    static let tInfo        = tBlue

    // MARK: - Hex initialiser
    init(hex: String) {
        var str = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: str).scanHexInt64(&value)
        let a, r, g, b: UInt64
        switch str.count {
        case 3:
            (a, r, g, b) = (255, (value >> 8)*17, (value >> 4 & 0xF)*17, (value & 0xF)*17)
        case 6:
            (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
        case 8:
            (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Font helpers

extension Font {
    static func tDisplay(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
    static func tLabel(_ size: CGFloat = 10) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    static func tMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .monospaced)
    }
}

// MARK: - View modifiers

extension View {
    /// Fills the background with the app's card color and a rounded corner.
    func tennisCard(radius: CGFloat = 16) -> some View {
        self
            .background(Color.tCard)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Uppercase tracking label style used throughout the app.
    func capsLabel() -> some View {
        self
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color.tText3)
            .tracking(2)
            .textCase(.uppercase)
    }
}
