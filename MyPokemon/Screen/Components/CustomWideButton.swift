//
//  customWideButton.swift
//  MyPokemon

import SwiftUI

struct CustomWideButton: View {
        let label: String
        let fontColor: Color
        let width: CGFloat
        let height: CGFloat
        let action: () -> Void
        
    var body: some View {
        Button(action: action, label: {
            Text(label)
                .frame(minWidth: width,minHeight: height)
                .foregroundColor(fontColor)
                .bold()
        })
        .frame(
            width: width,
            height: height
        )
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 8)
        .contentShape(Rectangle())
    }
}
