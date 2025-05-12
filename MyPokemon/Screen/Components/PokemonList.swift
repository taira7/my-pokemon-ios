//
//  AllPokemonList.swift
//  MyPokemon

import SwiftUI

struct PokemonList: View {
    @ObservedObject var pokemonListService: PokemonListService
    
    var body: some View {
        List(pokemonListService.pokemonDetails, id: \.id) { pokemon in
            PokemonListItem(pokemonDetail: pokemon)
        }
    }
}

//#Preview {
//    PokemonList()
//}
