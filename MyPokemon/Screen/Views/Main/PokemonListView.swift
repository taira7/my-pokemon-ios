//
//  PokemonListView.swift
//  MyPokemon


import SwiftUI

struct PokemonListView: View {
    @ObservedObject var pokemonListService = PokemonListService()
    @EnvironmentObject var authService:AuthService
    @State private var pokemonDetails: [PokemonDetail] = []
    
    @State var selectedTab:Int = 0
    @State var tabRange:[[Int]] = []
    @State var offset:Int = 0
    @State var uid:String = ""
    
    var body: some View {
        VStack{
            PokemonIdTab(
                pokemonListService: pokemonListService, selectedTab: $selectedTab,tabRange: $tabRange,offset: $offset)
                .padding(.top, 16)
            
            GeometryReader { geometry in
                TabView(selection: $selectedTab){
                    ForEach(0..<tabRange.count, id: \.self){ index in
                        ZStack {
                            
                            if selectedTab == index {
                                if pokemonListService.isLoading {
                                    ProgressView("読み込み中...")
                                        .background(Color.white.opacity(0.8))
                                    
                                } else {
                                    PokemonList(uid: uid, pokemonDetails: pokemonDetails)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                }
                            }else{
                                //他のページは白紙にする
                                Color.white
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            }
        }
        .navigationBarSetting(title: "ポケモン一覧", isVisible: true)
        .onAppear (){
            Task{
                pokemonDetails = await pokemonListService.fetchAllPokemonDetails(offset: offset)
            }
        }
        .onChange(of: selectedTab) {
            Task {
                offset = tabRange[selectedTab][0] - 1
                pokemonDetails = await pokemonListService.fetchAllPokemonDetails(offset: offset)
            }
        }
        .onAppear{
            Task{
                uid = authService.currentUser?.uid ?? ""
            }
        }
    }
}

#Preview {
    PokemonListView()
        .environmentObject(AuthService())
}
