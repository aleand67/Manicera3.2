//
//  Stylings.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

extension View {
    @ViewBuilder func showView(_ isShown: Bool = false) -> some View {
        if isShown {
            self.transition(.scale)
        } else {
            EmptyView()
        }
    }
}

extension Text {
    func boldHighRun(run: Int, max: Int?) -> some View {
        return self
            .fontWeight( (run == max! && run > 2) ? .heavy : .regular)
            .frame(width:35)
    }
}

extension Text {
    func textFieldPromptStyle(_ font: Font = .largeTitle, color: Color) -> some View {
        return self
                .font(font)
                .foregroundStyle(color.opacity(0.8))
                .allowsHitTesting(false)
    }
}

extension TextField {
    func playerNameStyle(_ font: Font = .largeTitle, color: Color, width: CGFloat) -> some View {
        return self
                .font(font)
                .frame(width: width)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accentColor(color)
                .foregroundStyle(color)
                .disableAutocorrection(true)
    }
}

struct GreenPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .background(Color("FeltGreen"))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct RedPill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .background(Color("InningRed"))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SavePill: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.largeTitle)
            .padding()
            .frame(width: 200)
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
        }
}
