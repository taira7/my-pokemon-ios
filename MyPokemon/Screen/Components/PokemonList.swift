//
//  PokemonList.swift
//  MyPokemon

import SwiftUI

struct PokemonList: View {
    let uid : String
    let pokemonDetails: [PokemonDetail]
    let firebaseService = FirebaseService()
    @State var isDisabled: Bool = false
    
    var body: some View {
        List(pokemonDetails, id: \.id) { pokemon in
            PokemonListItem(uid: uid, pokemonDetail: pokemon,isDisabled: isDisabled)
        }
        .listStyle(PlainListStyle())
    }
}
