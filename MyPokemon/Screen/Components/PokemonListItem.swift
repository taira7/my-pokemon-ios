//
//  PokemonListItem.swift
//  MyPokemon

import SwiftUI

struct PokemonListItem: View {
    var pokemonDetail: PokemonDetail
    @State var isFavorite: Bool = false
    
    var body: some View {
        HStack {
            if let imageURL = pokemonDetail.sprites.front_default {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 70, height: 70)
                            ProgressView()
                        }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                    case .failure:
                        // 失敗時の代替イメージ
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .padding(10)
                    @unknown default:
                        //別のケースが追加された時
                        EmptyView()
                    }
                }
            } else {
                // 画像データがnilのときのイメージ
                Image(systemName: "square.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(10)
            }
            VStack{
                    Text(pokemonDetail.name)
                        .font(.title2)
                    //  .background(Color.gray)
                        .frame(maxWidth: .infinity,alignment: .leading)
                
                HStack{
                    ForEach(pokemonDetail.types, id: \.type.name){ types in
                        Text(types.type.name)
                            .font(.headline)
                            .frame(width: 62)
                            .foregroundColor(Color.white)
                            .padding(.vertical,5)
                            .padding(.horizontal,10)
                            .background(PokemonTypeColor.getTypeColor(types.type.name))
                            .cornerRadius(6)
                    }
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.leading,12)
//                .background(Color.orange)
            }
//            .background(Color.red)
            
            if isFavorite {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25,alignment: .trailing)
                    .padding(.horizontal,8)
                    .foregroundStyle(Color.pink)
                    .onTapGesture {
                        isFavorite = false
                    }
            }else{
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25,alignment: .trailing)
                    .padding(.horizontal,8)
//                    .background(Color.red)
                    .foregroundStyle(Color.pink)
                    .onTapGesture {
                        isFavorite = true
                    }
            }
        }
        .listRowSeparator(.hidden)
//        .frame(width: .infinity, height: 100)
//        .cornerRadius(16)
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(Color.gray, lineWidth: 1)
//        )
    }
}

#Preview {
    let dummyPokemonDetail = PokemonDetail(
        id: 1,
        name: "Pikachu",
        height: 0.4,
        weight: 6.0,
        sprites: PokemonSprite(
            front_default: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png"),
            back_default: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/back/25.png")
        ),
        types: [
            PokemonTypeEntry(type: PokemonType(name: "electric"))
        ]
    )
    PokemonListItem(pokemonDetail: dummyPokemonDetail)
}
