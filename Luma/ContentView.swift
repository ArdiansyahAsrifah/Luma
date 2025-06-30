//
//  ContentView.swift
//  Luma
//
//  Created by Muhammad Ardiansyah Asrifah on 29/06/25.
//

import SwiftUI



struct ContentView: View {
    @State private var foregroundColor = Color.black
    @State private var backgroundColor = Color.white
    @State private var showingForegroundPicker = false
    @State private var showingBackgroundPicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderView()
            
            // Main Content
            HStack(spacing: 32) {
                // Left Panel - Color Selection
                ColorSelectionPanel(
                    foregroundColor: $foregroundColor,
                    backgroundColor: $backgroundColor,
                    showingForegroundPicker: $showingForegroundPicker,
                    showingBackgroundPicker: $showingBackgroundPicker
                )
                
                // Right Panel - Results
                ResultsPanel(
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor
                )
            }
            .padding(32)
        }
        .frame(width: 800, height: 600)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "eye.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("Luma")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("Color Contrast Checker")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(NSColor.separatorColor)),
            alignment: .bottom
        )
    }
}

struct ColorSelectionPanel: View {
    @Binding var foregroundColor: Color
    @Binding var backgroundColor: Color
    @Binding var showingForegroundPicker: Bool
    @Binding var showingBackgroundPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Colors")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 16) {
                ColorPickerRow(
                    title: "Foreground",
                    color: $foregroundColor,
                    showingPicker: $showingForegroundPicker,
                    icon: "textformat"
                )
                
                ColorPickerRow(
                    title: "Background",
                    color: $backgroundColor,
                    showingPicker: $showingBackgroundPicker,
                    icon: "rectangle.fill"
                )
            }
            
            // Preview Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Preview")
                    .font(.headline)
                    .fontWeight(.medium)
                
                PreviewCard(
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor
                )
            }
            
            Spacer()
        }
        .frame(maxWidth: 300)
    }
}

struct ColorPickerRow: View {
    let title: String
    @Binding var color: Color
    @Binding var showingPicker: Bool
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Button(action: {
                showingPicker.toggle()
            }) {
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(colorToHex(color))
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.medium)
                        Text("Click to change")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(12)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showingPicker) {
                ColorPicker("Select Color", selection: $color)
                    .labelsHidden()
                    .padding()
            }
        }
    }
}

struct PreviewCard: View {
    let foregroundColor: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sample Text")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(foregroundColor)
                
                Text("This is how your text will look with the selected color combination. Make sure it's readable!")
                    .font(.body)
                    .foregroundColor(foregroundColor)
                    .multilineTextAlignment(.leading)
            }
            
        }
        .padding(20)
        .background(backgroundColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
}

struct ResultsPanel: View {
    let foregroundColor: Color
    let backgroundColor: Color
    
    private var contrastRatio: Double {
        calculateContrastRatio(foregroundColor, backgroundColor)
    }
    
    private var wcagLevel: WCAGLevel {
        getWCAGLevel(contrastRatio)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Accessibility Results")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Contrast Ratio Card
            ContrastRatioCard(ratio: contrastRatio)
            
            // WCAG Compliance Cards
            VStack(spacing: 12) {
                WCAGComplianceCard(
                    title: "WCAG AA",
                    subtitle: "Normal Text",
                    requirement: "4.5:1",
                    passes: contrastRatio >= 4.5,
                    icon: "text.alignleft"
                )
                
                WCAGComplianceCard(
                    title: "WCAG AA",
                    subtitle: "Large Text",
                    requirement: "3:1",
                    passes: contrastRatio >= 3.0,
                    icon: "textformat.size.larger"
                )
                
                WCAGComplianceCard(
                    title: "WCAG AAA",
                    subtitle: "Normal Text",
                    requirement: "7:1",
                    passes: contrastRatio >= 7.0,
                    icon: "star.fill"
                )
                
                WCAGComplianceCard(
                    title: "WCAG AAA",
                    subtitle: "Large Text",
                    requirement: "4.5:1",
                    passes: contrastRatio >= 4.5,
                    icon: "star.circle.fill"
                )
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContrastRatioCard: View {
    let ratio: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "circle.lefthalf.striped.horizontal")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Contrast Ratio")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack {
                Text(String(format: "%.2f:1", ratio))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Visual representation
            ProgressView(value: min(ratio / 21.0, 1.0))
                .progressViewStyle(LinearProgressViewStyle(tint: ratio >= 4.5 ? .green : ratio >= 3.0 ? .orange : .red))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
}

struct WCAGComplianceCard: View {
    let title: String
    let subtitle: String
    let requirement: String
    let passes: Bool
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(requirement)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Image(systemName: passes ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title3)
                .foregroundColor(passes ? .green : .red)
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(NSColor.separatorColor), lineWidth: 1)
        )
    }
}

// MARK: - Helper Functions and Types

enum WCAGLevel {
    case fail, aa, aaa
}

func calculateContrastRatio(_ color1: Color, _ color2: Color) -> Double {
    let luminance1 = getLuminance(color1)
    let luminance2 = getLuminance(color2)
    
    let lighter = max(luminance1, luminance2)
    let darker = min(luminance1, luminance2)
    
    return (lighter + 0.05) / (darker + 0.05)
}

func getLuminance(_ color: Color) -> Double {
    let nsColor = NSColor(color)
    
    guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return 0 }
    
    let red = Double(rgbColor.redComponent)
    let green = Double(rgbColor.greenComponent)
    let blue = Double(rgbColor.blueComponent)
    
    func adjustColor(_ component: Double) -> Double {
        if component <= 0.03928 {
            return component / 12.92
        } else {
            return pow((component + 0.055) / 1.055, 2.4)
        }
    }
    
    let r = adjustColor(red)
    let g = adjustColor(green)
    let b = adjustColor(blue)
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
}

func getWCAGLevel(_ ratio: Double) -> WCAGLevel {
    if ratio >= 7.0 {
        return .aaa
    } else if ratio >= 4.5 {
        return .aa
    } else {
        return .fail
    }
}

func colorToHex(_ color: Color) -> String {
    let nsColor = NSColor(color)
    guard let rgbColor = nsColor.usingColorSpace(.sRGB) else { return "#000000" }
    
    let red = Int(rgbColor.redComponent * 255)
    let green = Int(rgbColor.greenComponent * 255)
    let blue = Int(rgbColor.blueComponent * 255)
    
    return String(format: "#%02X%02X%02X", red, green, blue)
}

#Preview {
    ContentView()
}
