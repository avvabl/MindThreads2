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
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .scaleEffect(1.0)
                .animation(.easeInOut(duration: 0.2), value: icon) // Smooth icon transition
        }
        .buttonStyle(PressedButtonStyle())
    }
}

// Custom button style for press animation
struct PressedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        FloatingActionButton(icon: "plus") {
            print("Plus tapped")
        }
        
        FloatingActionButton(icon: "chevron.down") {
            print("Chevron tapped")
        }
    }
    .padding()
} 