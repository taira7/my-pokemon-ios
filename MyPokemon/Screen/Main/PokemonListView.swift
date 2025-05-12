//
//  PokemonListView.swift
//  MyPokemon


import SwiftUI

struct PokemonListView: View {
    @ObservedObject var pokemonListService = PokemonListService()
    
    @State var selectedTab:Int = 0
    var body: some View {
        PokemonIdTab(pokemonListService: pokemonListService, selectedTab: $selectedTab)
        
//        if pokemonListService.isLoading {
//            ProgressView("")
//        } else {
//            PokemonList(pokemonListService: pokemonListService)
//        }
        
        GeometryReader { geometry in
            ZStack {
                if pokemonListService.isLoading {
                    ProgressView("読み込み中...")                        .background(Color.white.opacity(0.8))
                    
                } else {
                    PokemonList(pokemonListService: pokemonListService)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)

        }

        
    }
}

#Preview {
    PokemonListView()
}
