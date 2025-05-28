//
//  FirebaseService.swift
//  MyPokemon

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct UserInfo{
    let uid: String
    let name: String
    let email: String
}

struct FriendRequestInfo{
    let uid: String
    let name: String
    let email: String
    let isRecieved: Bool
}

final class FirebaseService {
    let db = Firestore.firestore()
    
//MARK: firebaseからのデータ取得
    
    //ユーザー情報の取得
    func fetchUserInfo(uid:String) async -> UserInfo{
        do{
            if uid == "" {
                return UserInfo(uid: "認証できません", name: "認証できません", email: "")
            }
            
            let userRef = db.collection("user").document(uid)
            let userSnapshot = try await userRef.getDocument()
            
            if let data = userSnapshot.data(){
                //webの方ではuidとemailしかないので，nameがない場合は，emailを代入する
                let id = data["id"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let name = data["name"] as? String ?? email
                
                return UserInfo(uid: id, name: name, email: email)
            }else{
                print("ユーザーが存在しません")
            }
        }catch{
            print("ユーザー情報の取得失敗しました: \(error)")
        }
        // データが取得できなかったときの値
        return UserInfo(uid: "取得できません", name: "取得できません", email: "")
    }
    
    //ユーザーのお気に入りのidを取得
    func fetchFavoritePokemons(uid:String) async -> [Int]{
        let favoritePokemonRef = db.collection("user").document(uid).collection("favorite")
        var favoritePokemonIds:[Int] = []
        do{
            let favoriteSnapshot = try await favoritePokemonRef.getDocuments()
            for document in favoriteSnapshot.documents{
                let data = document.data()
                if let favoritePokemonId = data["id"] as? Int{
                    favoritePokemonIds.append(favoritePokemonId)
                }
            }
            return favoritePokemonIds
        }catch{
            print("お気に入りの取得に失敗しました: \(error)")
            return []
        }
    }
    
    //フレンドの情報を獲得
    func fetchFriendsList(uid:String)async -> [UserInfo]{
        let friendsRef = db.collection("user").document(uid).collection("friends")
        
        var friendList:[UserInfo] = []
        do{
            let friendsSnapshot = try await friendsRef.getDocuments()
            for document in friendsSnapshot.documents{
                
                //webの方でid，emailしか設定していないので，nameがない場合はemailを使用する
                let data = document.data()
                let id = data["id"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let name = data["name"] as? String ?? email
                
                let friend = UserInfo(uid: id, name: name, email: email)
                friendList.append(friend)
            }
            return friendList
            
        }catch{
            print("フレンドリストの取得に失敗しました: \(error)")
            return []
        }
    }
    
    //フレンドリクエストの獲得
    func fetchFriendRequestList(uid:String)async -> [FriendRequestInfo]{
        let friendRequestRef = db.collection("user").document(uid).collection("friendRequest")
        
        var friendRequestList:[FriendRequestInfo] = []
        do{
            let friendRequestSnapshot = try await friendRequestRef.getDocuments()
            for document in friendRequestSnapshot.documents{
                let data = document.data()
                
                let id = data["id"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let name = data["name"] as? String ?? email
                let isRecieved = data["isRecieve"] as? Bool ?? false
                
                let friendRequestInfo = FriendRequestInfo(uid: id, name: name, email: email, isRecieved: isRecieved)
                friendRequestList.append(friendRequestInfo)
                
            }
            return friendRequestList
        }catch{
            print("フレンドリクエストリストの取得に失敗しました: \(error)")
            return []
        }
    }
    
//MARK: firebaseへのデータの登録
    
    //フレンド申請
    
    //お気に入り登録
    func addFavoritePokemon(uid:String,pokemonId:Int)async{
        let favoriteRef = db.collection("user").document(uid).collection("favorite")
        do {
            let newDocRef = favoriteRef.document() // ← .document() で自動IDのドキュメント参照
            try await newDocRef.setData([
                "id": pokemonId
            ])
            print("お気に入りに追加されました")
            
        } catch {
            print("お気に入り登録に失敗しました: \(error)")
        }
        
        
    }
    
    //フレンドの認証依頼
    
    //
    
//MARK: firebaseのデータの変更・削除
    
    //フレンドの削除
    
    //お気に入りの削除
    
}
