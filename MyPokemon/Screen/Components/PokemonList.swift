//
//  PokemonList.swift
//  MyPokemon

import SwiftUI

struct PokemonList: View {
    let pokemonDetails: [PokemonDetail]
    let firebaseService = FirebaseService()
    
    var body: some View {
        List(pokemonDetails, id: \.id) { pokemon in
            PokemonListItem(pokemonDetail: pokemon)
        }
        .listStyle(PlainListStyle())
    }
}
