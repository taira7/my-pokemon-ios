//
//  MyPokemonApp.swift
//  MyPokemon

import SwiftUI

@main
struct MyPokemonApp: App {
    var body: some Scene {
        WindowGroup {
            InitialView()
                .environmentObject(AuthState())
        }
    }
}
