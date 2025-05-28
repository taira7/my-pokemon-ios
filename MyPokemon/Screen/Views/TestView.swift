//
//  TestView.swift
//  MyPokemon
//

import SwiftUI
//import FirebaseCore
//import FirebaseFirestore

struct TestView: View {
    let firebaseService = FirebaseService()
//    var uid = "l2tujI1mIke0kIPnfPD7T0pnV8E2" //フレンドなどの全ての要素あり
//    var uid = "i1YhpOJwBDcYy2UQ1ok4QFEf4023" //フレンド複数名 dd
//    var uid = "BxmBk5ByuLVRWEuB7t0qmF1amPK2" //何もない
    var uid = "kiq4Q1y1XaeEsz1Gc4MgLGNTmZk2" //ee
    var friendUid = "qyn2mxfLAEQY9BAOcfDG53k17tc2" //test1
    
    var pokemonId: Int = 1
    
    
    var body: some View {
        Text("test")
            .onAppear {
                Task {
                    //                    await firebaseService.addFavoritePokemon(uid: uid, pokemonId: pokemonId)
//                                        await firebaseService.deleteFavoritePokemon(uid: uid, pokemonId: pokemonId)
//                                        await firebaseService.sendFriendRequest(uid: uid, friendUid: friendUid)
//                                        await firebaseService.deleteFriendRequest(uid: uid, friendUid: friendUid)
//                                        await firebaseService.addFriend(uid: uid, friendUid: friendUid)
//                                        await firebaseService.deleteFriend(uid: uid, friendUid: friendUid)
                    
//                    let user = await firebaseService.fetchUserInfo(uid: uid)
//                    print("loginUser🟥:",user)
//                    
//                    let friendList = await firebaseService.fetchFriendsList(uid: uid)
//                    print("friendList🟦:",friendList)
                    
//                    let favoritePokemonIds = await firebaseService.fetchFavoritePokemons(uid: uid)
//                    print("favoritePokemonIds🟢:",favoritePokemonIds)
                
//                    let friendRequestList =  await firebaseService.fetchFriendRequestList(uid: uid)
//                    print("friendRequestLst🟡:",friendRequestList)
                }
            }
        
    }
}

#Preview {
    TestView()
}
