//
//  MyPageView.swift
//  MyPokemon

import SwiftUI

struct MyPageView: View {
    @State private var userInfo: UserInfo?
    @State private var pokemonDetails: [PokemonDetail] = []
    @State private var favoritePokemonIds:[Int] = []
    @EnvironmentObject var authService: AuthService
    @ObservedObject var pokemonListService: PokemonListService = PokemonListService()
    let firebaseService: FirebaseService = FirebaseService()
    
    var body: some View {
        GeometryReader{ geometry in
                
            VStack{
                
                ProfileCard(
                    width: geometry.size.width * 0.9,
                    height: geometry.size.height * 0.2,
                    user: userInfo ?? UserInfo(uid: "", name: "", email: ""),
                    isShowEmail: true,
                    isShowButton: true
                )
                .padding(.top,20)
                
                Text("お気に入り")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.vertical,12)
                    .padding(.horizontal,28)
                
                Divider()
                
                if favoritePokemonIds.isEmpty {
                    Text("お気に入り：0件")
                }
                
                ZStack {
                    if pokemonListService.isLoading {
                        ProgressView("読み込み中...")
                            .background(Color.white.opacity(0.8))
                        
                    } else {
                        PokemonList(uid: authService.currentUser?.uid ?? "", pokemonDetails: pokemonDetails)
                    }
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
        .navigationBarSetting(title: "マイページ", isVisible: true)
        .NavigationBarIconSetting(name: "rectangle.portrait.and.arrow.right.fill", color: Color.white, isEnable: true, action: {
            Task{
                await authService.signOut()
            }
        })
        .onAppear(){
            Task{
                userInfo = await firebaseService.fetchUserInfo(uid: authService.currentUser?.uid ?? "")
                favoritePokemonIds = await firebaseService.fetchFavoritePokemons(uid: authService.currentUser?.uid ?? "")
                pokemonDetails = await pokemonListService.fetchFavoritePokemons(pokemonIds: favoritePokemonIds)
            }
        }
    }
}

#Preview {
    MyPageView()
        .environmentObject(AuthService())
}
