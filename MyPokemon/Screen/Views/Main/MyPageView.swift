//
//  MyPageView.swift
//  MyPokemon

import SwiftUI

struct DummyUserData: Identifiable {
//    var id: String = "00000000000000001"
//    var name: String = "abcdeabcdeabc"//13文字
//    var email: String = "0000000.0000000@gmail.com"
    
    var id: String = "UfBHZgtaP1bCEMl37nNkySA2mhm2"
    var name: String = "テストテスト"//13文字
    var email: String = "0000000.0000000@gmail.com"
}

struct MyPageView: View {
    @State var dummyUser: DummyUserData = .init()
    @State var userInfo: UserInfo = UserInfo(uid: "", name: "", email: "")
    @EnvironmentObject var authService: AuthService
    let firebaseService: FirebaseService = FirebaseService()
    
    //仮置き
    @ObservedObject var pokemonListService: PokemonListService = PokemonListService()
    
    var body: some View {
        GeometryReader{ geometry in
                
            VStack{
                
                ProfileCard(
                    width: geometry.size.width * 0.9,
                    height: geometry.size.height * 0.2,
                    user: userInfo,
                    isShowEmail: true
                )
                .padding(.top,20)
                
                Text("お気に入り")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                    .padding(.vertical,12)
                    .padding(.horizontal,28)
                
                ZStack {
                    if pokemonListService.isLoading {
                        ProgressView("読み込み中...")                        .background(Color.white.opacity(0.8))
                        
                    } else {
                        PokemonList(pokemonListService: pokemonListService)
                        
                    }
                }
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }
        .navigationBarSetting(title: "マイページ", isVisible: true)
        .NavigationBarIconSetting(name: "rectangle.portrait.and.arrow.right.fill", color: Color.white, isEnable: true, action: {
//            authService.signOut()
            authService.isAuth = false
        })
        .onAppear(){
            Task{
               userInfo = await firebaseService.fetchUserInfo(uid: authService.currentUser?.uid ?? "")
            }
        }
    }
}

#Preview {
    MyPageView()
        .environmentObject(AuthService())
}
