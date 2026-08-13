import AppKit
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let out = root.appendingPathComponent("assets/toesoft-brand-kit")
let source = out.appendingPathComponent("source")
let backgrounds = source.appendingPathComponent("backgrounds")

enum Theme: String { case dark, light }

let navy = NSColor(calibratedRed: 7/255, green: 13/255, blue: 33/255, alpha: 1)
let navy2 = NSColor(calibratedRed: 12/255, green: 22/255, blue: 51/255, alpha: 1)
let navy3 = NSColor(calibratedRed: 17/255, green: 30/255, blue: 66/255, alpha: 1)
let blue = NSColor(calibratedRed: 39/255, green: 117/255, blue: 251/255, alpha: 1)
let light = NSColor(calibratedRed: 246/255, green: 248/255, blue: 252/255, alpha: 1)
let light2 = NSColor(calibratedRed: 233/255, green: 238/255, blue: 248/255, alpha: 1)
let light3 = NSColor(calibratedRed: 221/255, green: 230/255, blue: 245/255, alpha: 1)
let white = NSColor(calibratedRed: 247/255, green: 249/255, blue: 252/255, alpha: 1)
let mutedDark = NSColor(calibratedRed: 169/255, green: 181/255, blue: 204/255, alpha: 1)
let mutedLight = NSColor(calibratedRed: 82/255, green: 96/255, blue: 121/255, alpha: 1)

func topRect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat, canvasH: CGFloat) -> NSRect {
    NSRect(x: x, y: canvasH - y - h, width: w, height: h)
}

func font(_ size: CGFloat, bold: Bool = false) -> NSFont {
    if let f = NSFont(name: bold ? "PingFangSC-Semibold" : "PingFangSC-Regular", size: size) { return f }
    return bold ? NSFont.boldSystemFont(ofSize: size) : NSFont.systemFont(ofSize: size)
}

func render(width: Int, height: Int, output: URL, draw: (CGFloat, CGFloat) -> Void) {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: width, height: height)
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: rep)!
    context.imageInterpolation = .high
    NSGraphicsContext.current = context
    draw(CGFloat(width), CGFloat(height))
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()
    let data = rep.representation(using: .png, properties: [.compressionFactor: 1.0])!
    try! data.write(to: output)
}

func fill(_ rect: NSRect, color: NSColor, radius: CGFloat = 0) {
    color.setFill()
    if radius > 0 { NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill() }
    else { rect.fill() }
}

func background(_ theme: Theme, width: CGFloat, height: CGFloat) {
    fill(NSRect(x: 0, y: 0, width: width, height: height), color: theme == .dark ? navy : light)
    let a = theme == .dark ? navy2 : light2
    let b = theme == .dark ? navy3 : light3
    fill(topRect(width * 0.58, -36, width * 0.29, height * 0.40, canvasH: height), color: a, radius: min(width, height) * 0.055)
    fill(topRect(width * 0.81, height * 0.34, width * 0.27, height * 0.37, canvasH: height), color: b, radius: min(width, height) * 0.055)
    fill(topRect(width * 0.87, height * 0.36, width * 0.20, height * 0.20, canvasH: height), color: blue, radius: min(width, height) * 0.045)
    fill(topRect(width * 0.60, height * 0.76, width * 0.29, height * 0.30, canvasH: height), color: a, radius: min(width, height) * 0.055)
}

func image(_ path: URL) -> NSImage { NSImage(contentsOf: path)! }

func drawImage(_ img: NSImage, x: CGFloat, y: CGFloat, width: CGFloat, canvasH: CGFloat) {
    let ratio = img.size.height / img.size.width
    img.draw(in: topRect(x, y, width, width * ratio, canvasH: canvasH), from: .zero, operation: .sourceOver, fraction: 1)
}

func drawText(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, color: NSColor, bold: Bool = false) {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font(size, bold: bold),
        .foregroundColor: color
    ]
    (text as NSString).draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
}

let avatarDark = image(root.appendingPathComponent("assets/toesoft-github-avatar-v1.png"))
let mark = image(source.appendingPathComponent("mark-clean-4x.png"))
let squareDark = image(backgrounds.appendingPathComponent("frosted-square-dark.png"))
let squareLight = image(backgrounds.appendingPathComponent("frosted-square-light.png"))
let wideDark = image(backgrounds.appendingPathComponent("frosted-wide-dark.png"))
let wideLight = image(backgrounds.appendingPathComponent("frosted-wide-light.png"))

func titleColor(_ theme: Theme) -> NSColor { theme == .dark ? white : navy }
func secondaryColor(_ theme: Theme) -> NSColor { theme == .dark ? mutedDark : mutedLight }
func squareBackground(_ theme: Theme) -> NSImage { theme == .dark ? squareDark : squareLight }
func wideBackground(_ theme: Theme) -> NSImage { theme == .dark ? wideDark : wideLight }

func cover(_ img: NSImage, width: CGFloat, height: CGFloat) {
    let sourceRatio = img.size.width / img.size.height
    let targetRatio = width / height
    var sourceRect = NSRect(origin: .zero, size: img.size)
    if sourceRatio > targetRatio {
        let wantedWidth = img.size.height * targetRatio
        sourceRect.origin.x = (img.size.width - wantedWidth) / 2
        sourceRect.size.width = wantedWidth
    } else {
        let wantedHeight = img.size.width / targetRatio
        sourceRect.origin.y = (img.size.height - wantedHeight) / 2
        sourceRect.size.height = wantedHeight
    }
    img.draw(in: NSRect(x: 0, y: 0, width: width, height: height), from: sourceRect, operation: .sourceOver, fraction: 1)
}

func originalStyleWordmarkFont(_ size: CGFloat) -> NSFont {
    // The selected source uses a neutral grotesk: flat terminals, compact
    // lowercase forms and no rounded-display treatment.
    return NSFont(name: "HelveticaNeue-Bold", size: size)
        ?? NSFont.systemFont(ofSize: size, weight: .bold)
}

func createLockupAsset(textColor: NSColor, output: URL) {
    // Four-times the measured source lockup (1171×248). The original visible
    // mark occupied x=0…290 and the wordmark occupied x=345…1171. Both are
    // optically centered around y≈125 in the source, so they are placed on one
    // shared canvas and subsequently scaled as one indivisible component.
    render(width: 4684, height: 992, output: output) { _, h in
        drawImage(mark, x: 0, y: -4, width: 1182, canvasH: h)
        let text = "ToeSoft" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: originalStyleWordmarkFont(935),
            .foregroundColor: textColor,
            .kern: -14
        ]
        // Measured source: mark 246 px high, wordmark 175 px high, text center
        // 10 px below the mark center. Values below are the 4× equivalents.
        text.draw(at: NSPoint(x: 1380, y: -72), withAttributes: attrs)
    }
}

let lockupDarkURL = source.appendingPathComponent("lockup-clean-dark-4x.png")
let lockupLightURL = source.appendingPathComponent("lockup-clean-light-4x.png")
createLockupAsset(textColor: navy, output: lockupDarkURL)
createLockupAsset(textColor: white, output: lockupLightURL)
let lockupDark = image(lockupDarkURL)
let lockupLight = image(lockupLightURL)

func lockup(_ theme: Theme) -> NSImage { theme == .dark ? lockupLight : lockupDark }

for theme in [Theme.dark, Theme.light] {
    let avatarPath = out.appendingPathComponent("avatar/avatar-\(theme.rawValue)-1024.png")
    render(width: 1024, height: 1024, output: avatarPath) { w, h in
        if theme == .dark {
            avatarDark.draw(in: NSRect(x: 0, y: 0, width: w, height: h), from: .zero, operation: .sourceOver, fraction: 1)
        } else {
            fill(NSRect(x: 0, y: 0, width: w, height: h), color: light)
            drawImage(mark, x: 187, y: 232, width: 650, canvasH: h)
        }
    }

    let squarePath = out.appendingPathComponent("square/brand-square-\(theme.rawValue)-1080.png")
    render(width: 1080, height: 1080, output: squarePath) { w, h in
        cover(squareBackground(theme), width: w, height: h)
        drawImage(lockup(theme), x: 160, y: 330, width: 760, canvasH: h)
        drawText("软件开发工作室", x: 330, y: 320, size: 52, color: secondaryColor(theme))
    }

    let bannerPath = out.appendingPathComponent("banner/banner-\(theme.rawValue)-1600x400.png")
    render(width: 1600, height: 400, output: bannerPath) { w, h in
        cover(wideBackground(theme), width: w, height: h)
        drawImage(lockup(theme), x: 128, y: 105, width: 700, canvasH: h)
    }

    let githubPath = out.appendingPathComponent("github/github-social-\(theme.rawValue)-1280x640.png")
    render(width: 1280, height: 640, output: githubPath) { w, h in
        cover(wideBackground(theme), width: w, height: h)
        drawImage(lockup(theme), x: 102, y: 220, width: 670, canvasH: h)
        drawText("Software Development Studio", x: 106, y: 166, size: 34, color: secondaryColor(theme))
    }

    let coverPath = out.appendingPathComponent("xianyu/xianyu-cover-\(theme.rawValue)-1080.png")
    render(width: 1080, height: 1080, output: coverPath) { w, h in
        cover(squareBackground(theme), width: w, height: h)
        drawImage(lockup(theme), x: 96, y: 88, width: 430, canvasH: h)
        drawText("软件开发｜按需定制", x: 96, y: 555, size: 72, color: titleColor(theme), bold: true)
        drawText("小程序 · 网站 · App · 后台系统", x: 98, y: 470, size: 36, color: secondaryColor(theme))
        fill(NSRect(x: 96, y: 396, width: 544, height: 12), color: blue, radius: 6)
    }

    let servicesPath = out.appendingPathComponent("xianyu/xianyu-services-\(theme.rawValue)-1080.png")
    render(width: 1080, height: 1080, output: servicesPath) { w, h in
        cover(squareBackground(theme), width: w, height: h)
        drawText("我们的工作范围", x: 86, y: 890, size: 68, color: titleColor(theme), bold: true)
        drawText("ToeSoft · 软件开发工作室", x: 88, y: 825, size: 27, color: secondaryColor(theme))
        let left = ["微信小程序", "网站 / H5", "App 开发", "管理后台 / 企业系统"]
        let right = ["API / 后端开发", "Bug 修复 / 二次开发", "爬虫 / 数据处理", "AI 应用 / 智能客服"]
        let moduleColor = theme == .dark ? NSColor(calibratedWhite: 0.08, alpha: 0.72) : NSColor(calibratedWhite: 1, alpha: 0.62)
        for i in 0..<4 {
            let top = CGFloat(300 + i * 155)
            fill(topRect(76, top, 434, 112, canvasH: h), color: moduleColor, radius: 28)
            fill(topRect(550, top, 434, 112, canvasH: h), color: moduleColor, radius: 28)
            drawText(left[i], x: 112, y: h - top - 72, size: 28, color: secondaryColor(theme))
            drawText(right[i], x: 586, y: h - top - 72, size: 28, color: secondaryColor(theme))
        }
    }
}

print("Rendered ToeSoft masters with native macOS typography")
