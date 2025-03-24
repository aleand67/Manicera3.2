//
//  TextStyles.swift
//  Manicera
//
//  Created by Alejandro Andreotti on 3/14/25.
//

import SwiftUI

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
                .foregroundColor(color.opacity(0.8))
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
                .foregroundColor(color)
                .disableAutocorrection(true)
    }
}
