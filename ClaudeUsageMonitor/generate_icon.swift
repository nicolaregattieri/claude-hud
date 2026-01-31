import Cocoa

// MARK: - App Icon (1024x1024)
let iconSize = NSSize(width: 1024, height: 1024)
let menuSize = NSSize(width: 18, height: 18) // Points for Menu Bar

func drawMainIcon(in rect: NSRect) {
    let context = NSGraphicsContext.current!.cgContext
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.22, yRadius: rect.height * 0.22)
    path.addClip()
    
    let bgColors = [
        NSColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0).cgColor,
        NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0).cgColor
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: rect.height), end: CGPoint(x: 0, y: 0), options: [])
    
    // Activity Ring
    let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    let radius = rect.width * 0.35
    let lineWidth = rect.width * 0.08
    let ringPath = NSBezierPath()
    ringPath.appendArc(withCenter: center, radius: radius, startAngle: -40, endAngle: 220, clockwise: false)
    
    context.saveGState()
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)
    context.addPath(ringPath.cgPath)
    context.replacePathWithStrokedPath()
    context.clip()
    let ringColors = [
        NSColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0).cgColor,
        NSColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0).cgColor
    ] as CFArray
    let ringGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: ringColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(ringGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: rect.height), options: [])
    context.restoreGState()
    
    // Core Pulse
    let coreRadius = rect.width * 0.12
    let corePath = NSBezierPath(ovalIn: NSRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
    context.saveGState()
    context.addPath(corePath.cgPath)
    context.setFillColor(NSColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0).cgColor)
    context.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8).cgColor)
    context.fillPath()
    context.restoreGState()
}

func drawMenuIcon(in rect: NSRect) {
    let context = NSGraphicsContext.current!.cgContext
    let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    
    // Ring (Ultra small and thin for maximum elegance)
    let radius = rect.width * 0.24 // Reduced from 0.28
    let lineWidth = rect.width * 0.07 // Thinner stroke
    let ringPath = NSBezierPath()
    ringPath.appendArc(withCenter: center, radius: radius, startAngle: -40, endAngle: 220, clockwise: false)
    
    context.saveGState()
    context.setStrokeColor(NSColor.black.cgColor)
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)
    context.addPath(ringPath.cgPath)
    context.strokePath()
    context.restoreGState()
    
    // Center Dot (Tiny pulse)
    let coreRadius = rect.width * 0.08 // Smaller dot
    let corePath = NSBezierPath(ovalIn: NSRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
    context.saveGState()
    context.setFillColor(NSColor.black.cgColor)
    context.addPath(corePath.cgPath)
    context.fillPath()
    context.restoreGState()
}

// Save helper
func savePNG(image: NSImage, name: String) {
    if let tiffData = image.tiffRepresentation,
       let bitmap = NSBitmapImageRep(data: tiffData),
       let pngData = bitmap.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(name)
        try! pngData.write(to: url)
        print("Generated \(name)")
    }
}

// 1. Generate App Icon
let appIcon = NSImage(size: iconSize)
appIcon.lockFocus()
drawMainIcon(in: NSRect(origin: .zero, size: iconSize))
appIcon.unlockFocus()
savePNG(image: appIcon, name: "icon_1024.png")

// 2. Generate Menu Icon (Template)
// We generate 36x36 for @2x menu bars
let menuImage = NSImage(size: NSSize(width: 36, height: 36))
menuImage.lockFocus()
drawMenuIcon(in: NSRect(origin: .zero, size: NSSize(width: 36, height: 36)))
menuImage.unlockFocus()
savePNG(image: menuImage, name: "menu_icon_36.png")
