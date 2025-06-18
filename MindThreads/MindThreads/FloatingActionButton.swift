//
//  FloatingActionButton.swift
//  MindThreads
//
//  Created by Avvab Lababidi on 18.06.2025.
//

import SwiftUI

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    let backgroundColor: Color
    
    init(icon: String, backgroundColor: Color = .blue, action: @escaping () -> Void) {
        self.icon = icon
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(backgroundColor)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(FloatingButtonStyle())
        .accessibilityLabel("Add new task")
    }
}

// Custom button style for floating action button
struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            FloatingActionButton(icon: "plus") {
                print("Add button tapped")
            }
            .padding()
        }
    }
    .background(Color.gray.opacity(0.1))
} 