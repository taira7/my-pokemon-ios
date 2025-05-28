//
//  TestView.swift
//  MyPokemon
//

import SwiftUI
//import FirebaseCore
//import FirebaseFirestore

struct TestView: View {
    let firebaseService = FirebaseService()
    var uid = "l2tujI1mIke0kIPnfPD7T0pnV8E2" //フレンドなどの全ての要素あり
//    var uid = "i1YhpOJwBDcYy2UQ1ok4QFEf4023" //フレンド複数名 dd
//    var uid = "BxmBk5ByuLVRWEuB7t0qmF1amPK2" //何もない
    
    
    var body: some View {
        Text("test")
            .onAppear {
                Task {
                    let user = await firebaseService.fetchUserInfo(uid: uid)
                    print("loginUser🟥:",user)
                    
                    let friendList = await firebaseService.fetchFriendsList(uid: uid)
                    print("friendList🟦:",friendList)
                    
                    let favoritePokemonIds = await firebaseService.fetchFavoritePokemons(uid: uid)
                    print("favoritePokemonIds🟢:",favoritePokemonIds)
                
                    let friendRequestList =  await firebaseService.fetchFriendRequestList(uid: uid)
                    print("friendRequestLst🟡:",friendRequestList)
                }
            }
    }
}

#Preview {
    TestView()
}
