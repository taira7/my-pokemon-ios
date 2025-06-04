//
//  PokemonIdTab.swift
//  MyPokemon

import SwiftUI

struct PokemonIdTab: View {
    @ObservedObject var pokemonListService:PokemonListService
    @Binding var selectedTab: Int
    @Binding var tabRange: [[Int]]
    @Binding var offset: Int
    
    let itemWidth:CGFloat = 128
    let itemHeight:CGFloat = 44
    
    func generateTabRange(with totalCount: Int) {
        tabRange.removeAll()
        
        let count = totalCount / pokemonListService.limit
        
        var start = 1
        var end = pokemonListService.limit
        
        for _ in 0..<count {
            tabRange.append([start, end])
            start += pokemonListService.limit
            end += pokemonListService.limit
        }

        //余った分の挿入
        if totalCount % pokemonListService.limit != 0 {
            tabRange.append([start, totalCount])
        }
    }
    
    var body: some View {
        ScrollViewReader{ proxy in
            ScrollView(.horizontal){
                HStack {
                    Spacer(minLength: itemWidth)
                    ForEach(tabRange.indices,id: \.self){ index in
                        let range = tabRange[index]
                        VStack{
                            Text("\(range[0])-\(range[1])")
                            Rectangle()
                                .fill(Color("ThemeColor"))
                                .frame(height: 3)
                                .cornerRadius(4)
                                .opacity(selectedTab ==  index ? 1.0 : 0.1)
                        }
                        .frame(width: itemWidth,height: itemHeight)
                        .onTapGesture {
                            if selectedTab != index {
                                selectedTab = index
                                let range = tabRange[index]
                                offset = range[0] - 1
                            }
                        }
                        .onChange(of: selectedTab){
                            withAnimation{
                                proxy.scrollTo(selectedTab,anchor: .center)
                            }
                        }
                    }
                    Spacer(minLength: itemWidth)
                }
            }
            .onAppear{
                Task{
                    let response =  await pokemonListService.fetchPokemonListResponse(offset: 0)
                    if let response = response {
                        generateTabRange(with: response.count)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}
