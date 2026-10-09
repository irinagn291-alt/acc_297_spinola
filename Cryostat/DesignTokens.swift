import SwiftUI

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #2C1B1F
    static let bg = Color(red: 0.172549, green: 0.105882, blue: 0.121569)
    static let bgHex = "#2C1B1F"
    /// #3D2D29
    static let surface = Color(red: 0.239216, green: 0.176471, blue: 0.160784)
    static let surfaceHex = "#3D2D29"
    /// #F4F1F2
    static let ink = Color(red: 0.956863, green: 0.945098, blue: 0.949020)
    static let inkHex = "#F4F1F2"
    /// #E37F63
    static let accent = Color(red: 0.890196, green: 0.498039, blue: 0.388235)
    static let accentHex = "#E37F63"
    /// #BFB0B4
    static let muted = Color(red: 0.749020, green: 0.690196, blue: 0.705882)
    static let mutedHex = "#BFB0B4"
    static let fontFamily = "Futura"
}
