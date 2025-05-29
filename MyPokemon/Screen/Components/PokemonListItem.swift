//
//  PokemonListItem.swift
//  MyPokemon

import SwiftUI

struct PokemonListItem: View {
    var pokemonDetail: PokemonDetail
    @State var isFavorite: Bool = false
    @State var favoritePokemonIds: [Int] = []
    
    @EnvironmentObject var authService: AuthService
    let firebaseService: FirebaseService = FirebaseService()
    @State var uid:String = ""
    
    func isFavoritePokemon() -> Bool {
        return favoritePokemonIds.contains(pokemonDetail.id)
    }
    
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
            }
            
            if isFavorite {
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25,alignment: .trailing)
                    .padding(.horizontal,8)
                    .foregroundStyle(Color.pink)
                    .onTapGesture {
                        Task{
                            await firebaseService.deleteFavoritePokemon(uid: uid, pokemonId: pokemonDetail.id)
                            isFavorite = false
                        }
                    }
            }else{
                Image(systemName: "heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25,alignment: .trailing)
                    .padding(.horizontal,8)
                    .foregroundStyle(Color.pink)
                    .onTapGesture {
                        Task{
                            await firebaseService.addFavoritePokemon(uid: uid, pokemonId: pokemonDetail.id)
                            isFavorite = true
                        }
                    }
            }
        }
        .listRowSeparator(.hidden)
        .onAppear(){
                Task{
                    uid = authService.currentUser?.uid ?? ""
                    favoritePokemonIds = await firebaseService.fetchFavoritePokemons(uid: uid)
                    isFavorite = isFavoritePokemon()
                }
        }
    }
}
