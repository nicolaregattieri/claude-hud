import Cocoa

// MARK: - Configuration
let size = NSSize(width: 1024, height: 1024)
let scale: CGFloat = 1.0 // Main scale
let filename = "icon_1024.png"

// MARK: - Drawing Code
func drawIcon(in rect: NSRect) {
    let context = NSGraphicsContext.current!.cgContext
    
    // 1. Base Squircle (macOS Shape)
    let path = NSBezierPath(roundedRect: rect, xRadius: rect.width * 0.22, yRadius: rect.height * 0.22)
    path.addClip()
    
    // Background Gradient (Dark Mode feel)
    let bgColors = [
        NSColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0).cgColor, // Top (lighter dark)
        NSColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1.0).cgColor  // Bottom (deep dark)
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: bgColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: rect.height), end: CGPoint(x: 0, y: 0), options: [])
    
    // 2. Subtle Glass Shine (Top)
    context.saveGState()
    let shinePath = NSBezierPath()
    shinePath.move(to: CGPoint(x: 0, y: rect.height))
    shinePath.line(to: CGPoint(x: rect.width, y: rect.height))
    shinePath.line(to: CGPoint(x: rect.width, y: rect.height * 0.4))
    shinePath.curve(to: CGPoint(x: 0, y: rect.height * 0.4), controlPoint1: CGPoint(x: rect.width * 0.7, y: rect.height * 0.2), controlPoint2: CGPoint(x: rect.width * 0.3, y: rect.height * 0.2))
    shinePath.close()
    
    let shineColors = [
        NSColor(white: 1.0, alpha: 0.1).cgColor,
        NSColor(white: 1.0, alpha: 0.0).cgColor
    ] as CFArray
    let shineGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: shineColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(shineGradient, start: CGPoint(x: 0, y: rect.height), end: CGPoint(x: 0, y: rect.height * 0.4), options: [])
    context.restoreGState()
    
    // 3. Activity Gauge / Flame Ring
    // Center point
    let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
    let radius = rect.width * 0.35
    let lineWidth = rect.width * 0.08
    
    let ringPath = NSBezierPath()
    // 270 degrees arc (open at bottom)
    ringPath.appendArc(withCenter: center, radius: radius, startAngle: -40, endAngle: 220, clockwise: false)
    
    // Gradient Stroke for Ring
    context.saveGState()
    context.setLineWidth(lineWidth)
    context.setLineCap(.round)
    context.addPath(ringPath.cgPath)
    context.replacePathWithStrokedPath()
    context.clip()
    
    let ringColors = [
        NSColor(red: 1.0, green: 0.3, blue: 0.0, alpha: 1.0).cgColor, // Orange/Red
        NSColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0).cgColor  // Yellow/Amber
    ] as CFArray
    let ringGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: ringColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(ringGradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: rect.width, y: rect.height), options: [])
    context.restoreGState()
    
    // 4. Center Pulse / Flame Core
    let coreRadius = rect.width * 0.12
    let corePath = NSBezierPath(ovalIn: NSRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2))
    
    context.saveGState()
    context.addPath(corePath.cgPath)
    context.setFillColor(NSColor(red: 1.0, green: 0.4, blue: 0.0, alpha: 1.0).cgColor)
    
    // Bloom/Glow effect
    context.setShadow(offset: .zero, blur: 30, color: NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.8).cgColor)
    context.fillPath()
    context.restoreGState()
}

// MARK: - Image Generation
let image = NSImage(size: size)
image.lockFocus()
drawIcon(in: NSRect(origin: .zero, size: size))
image.unlockFocus()

// MARK: - Save
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(filename)
    try! pngData.write(to: url)
    print("Generated \(filename)")
}
