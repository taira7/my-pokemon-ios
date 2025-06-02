//
//  FriendProfileView.swift
//  MyPokemon

import SwiftUI

struct FriendProfileView: View {
    @Binding var isFriendProfilePresented: Bool
    @Binding var friendInfo: UserInfo
    
    @State private var pokemonDetails: [PokemonDetail] = []
    @State private var favoritePokemonIds:[Int] = []
    @ObservedObject var pokemonListService: PokemonListService = PokemonListService()
    
    @EnvironmentObject var authService: AuthService
    let firebaseService: FirebaseService = FirebaseService()
    
    let gradient = Gradient(stops: [
        .init(color: Color(red: 1.0, green: 0.6, blue: 0.2), location: 0.0),
        .init(color: Color(red: 1.0, green: 0.4, blue: 0.4), location: 1.0)
    ])
    
    var body: some View {
        GeometryReader{ geometry in
                
            VStack{
                
                ZStack{
                    LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    ProfileCard(
                        width: geometry.size.width * 0.9,
                        height: geometry.size.height * 0.2,
                        user: friendInfo,
                        isShowEmail: true,
                        isShowButton: true
                    )
                    .padding(.top,16)
                    
                }
                .frame(height: geometry.size.height * 0.3)
                .overlay(alignment: .top){
                    HStack{
                        
                        Button(action: {
                            Task{
                                await firebaseService.deleteFriend(uid: authService.currentUser?.uid ?? "", friendUid: friendInfo.uid)
                                isFriendProfilePresented = false
                            }
                        }) {
                            
                            ZStack{
                                Capsule()
                                    .fill(Color.red)
                                    .frame(width: 68, height: 30)
                                    
                                Text("削除")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading,24)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isFriendProfilePresented = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30,alignment: .trailing)
                                .foregroundColor(.white)
                                .shadow(radius: 2)
                                .padding(.trailing,24)
                                .padding(.bottom,0)
                        }
                    }
                }
                

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
                        PokemonList(uid:friendInfo.uid, pokemonDetails: pokemonDetails, isDisabled: true)
                    }
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
            
        }
        .onAppear(){
            Task{
                favoritePokemonIds = await firebaseService.fetchFavoritePokemons(uid: friendInfo.uid)
                pokemonDetails = await pokemonListService.fetchFavoritePokemons(pokemonIds: favoritePokemonIds)
            }
        }
    }
}

#Preview {
    @Previewable @State var isFriendProfilePresented: Bool = false
    @Previewable @State var friendInfo:UserInfo = .init(uid: "tIo3WbAHwFe0SKMaGGIdzT7yjvh2", name: "user2", email:"user2@gmail.com")
    FriendProfileView(isFriendProfilePresented: $isFriendProfilePresented, friendInfo: $friendInfo)
        .environmentObject(AuthService())
}
