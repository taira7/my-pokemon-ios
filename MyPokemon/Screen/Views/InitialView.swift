//
//  InitialView.swift
//  MyPokemon

import SwiftUI

struct InitialView: View {
//        @State private var selectedTab : String = "PokemonListView"
    @State private var selectedTab : String = "MyPageView"
    
    @EnvironmentObject var authService:AuthService
    
    init() {
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
    }
    
    var body: some View {
        ZStack{
            if !authService.isAuth{
                SignView()
            }else{
                
                if authService.currentUser != nil {
                    TabView(selection:$selectedTab){
                        NavigationStack{
                            FriendListView()
                        }
                        .tabItem{
                            Image(systemName: "person.3")
                            Text("フレンド")
                        }
                        .tag("FriendListView")
                        
                        NavigationStack{
                            PokemonListView()
                        }
                        .tabItem{
                            Image(systemName: "square.2.layers.3d.top.filled")
                            Text("ポケモン")
                        }
                        .tag("PokemonListView")
                        
                        NavigationStack{
                            MyPageView()
                        }
                        .tabItem{
                            Image(systemName: "person.crop.circle")
                            Text("マイページ")
                        }
                        .tag("MyPageView")
                    }
                    .accentColor(.orange)
                }else{
                    ProgressView()
                }
            }
        }
    }
}

#Preview {
    InitialView()
        .environmentObject(AuthService())
}
