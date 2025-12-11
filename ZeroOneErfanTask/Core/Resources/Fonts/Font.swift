import UIKit

// MARK: - Load fonts
public extension UIFont {
    private static var loaded = false

    private static let allFonts = [
        "PoppinsLatin-SemiBold.ttf",
        "PoppinsLatin-Regular.ttf",
        "PoppinsLatin-Medium.ttf",
        "PoppinsLatin-Light.ttf",
        "PoppinsLatin-Bold.ttf",
    ]

    static func loadAll() {
        class Dummy {}
        guard !loaded else { return }
        loaded = true
        let fontsBundle = Bundle(for: Dummy.self)
        allFonts.forEach { fontName in
            let parts = fontName.split(separator: ".")
            guard let file = parts.first.map(String.init),
                  let ext = parts.last.map(String.init),
                  let url = fontsBundle.url(forResource: file, withExtension: ext) else { return }
            CTFontManagerRegisterFontsForURL(url as CFURL, CTFontManagerScope.process, nil)
        }
    }
}
