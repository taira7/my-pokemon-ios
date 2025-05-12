//
//  FriendListView.swift
//  MyPokemon

import SwiftUI

struct DummyFriendData{
    let id:String
    let name:String
    let email:String
}

struct FriendListView: View {
    var dummyFriends:[DummyUserData] = [
        .init(id: "UfBHZgtaP1bCEMl37nNkySA2mhm2", name: "aaaaaaaaaaaaaaaaaaaaaaaaaaa", email: "a@gmail.com"),
        .init(id: "2", name: "b", email: "bbbbbbbbbbbbb@gmail.com"),
        .init(id: "3", name: "c", email: "c@gmail.com"),
        .init(id: "4", name: "d", email: "d@gmail.com"),
        .init(id: "5", name: "e", email: "e@gmail.com"),
        .init(id: "6", name: "f", email: "f@gmail.com")
    ]
    @State var tapCount = 0
    
    var body: some View {
        
            GeometryReader{ geometry in
                VStack{
                    Text("フレンド一覧")
                    List{
                        ForEach(dummyFriends){ friend in
                            ProfileCard(
                                width: geometry.size.width * 0.85,
                                height: geometry.size.height * 0.2,
                                user: friend,
                                isShowEmail: false)
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                            .contentShape(Rectangle()) // タップ領域の指定
                            .onTapGesture {
                                tapCount += 1
                                print("list tapped🟢: \(tapCount)")
                            }      
                        }
                        .listRowSeparator(.hidden)
                    }
                    
                }
            }
        
        .navigationBarSetting(title: "フレンド", isVisible: true)
    }
}

#Preview {
    FriendListView()
}
