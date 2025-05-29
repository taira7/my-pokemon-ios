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
    var isRecieved: Bool //false->申請を送った側，true->申請を受け取った側
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
                return UserInfo(uid: "ユーザーが存在しません", name: "ユーザーが存在しません", email: "")
            }
            
        }catch{
            print("ユーザー情報の取得失敗しました: \(error)")
            return UserInfo(uid: "取得できません", name: "取得できません", email: "")
        }
    }
    
    //ユーザーのお気に入りのポケモンのidを取得
    func fetchFavoritePokemons(uid:String) async -> [Int]{
        if(uid == ""){
            print("uidが空です")
            return []
        }
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
    
    //フレンドの情報を取得
    func fetchFriendsList(uid:String)async -> [UserInfo]{
        if(uid == ""){
            print("uidが空です")
            return []
        }
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
    
    //フレンドリクエストの取得
    func fetchFriendRequestList(uid:String)async -> [FriendRequestInfo]{
        if(uid == ""){
            print("uidが空です")
            return []
        }
        let friendRequestRef = db.collection("user").document(uid).collection("friendRequest")
        
        var friendRequestList:[FriendRequestInfo] = []
        do{
            let friendRequestSnapshot = try await friendRequestRef.getDocuments()
            for document in friendRequestSnapshot.documents{
                let data = document.data()
                print("documentID:",document.documentID)
                
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
    //setData -- documentIDを指定 documentIDが既に存在する場合，上書きされる（同じ内容の重複なし）
    //addDocument -- documentIDは自動生成　（同じ内容の重複あり）
    
    //アカウント登録時のユーザー登録
    func addUser(uid: String, name: String, email: String)async -> Void{
        if(uid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        
        let userRef = db.collection("user").document(uid)
        do {
            try await userRef.setData([
                "id": uid,
                "name": name,
                "email": email
            ])
            print("ユーザー登録に成功しました")
        } catch {
            print("ユーザー登録に失敗しました: \(error)")
        }
    }
    
    //お気に入り登録
    func addFavoritePokemon(uid:String,pokemonId:Int)async -> Void{
        if(uid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        let favoriteRef = db.collection("user").document(uid).collection("favorite")
        do {
            try await favoriteRef.addDocument(data:[
                "id": pokemonId
            ])
            print("お気に入りに追加されました")
        } catch {
            print("お気に入り登録に失敗しました: \(error)")
        }
    }
    
    //フレンドの登録
    func addFriend(uid:String,friendUid:String)async -> Void{
        if(uid == "" || friendUid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        
        let userInfo = await fetchUserInfo(uid: uid)
        let friendInfo = await fetchUserInfo(uid: friendUid)
        
        let userFriendRef = db.collection("user").document(uid).collection("friends")
        let targetFriendRef = db.collection("user").document(friendUid).collection("friends")
        
        do{
            //自分側のフレンドに追加
            let newUserFriendRef = userFriendRef.document(friendUid)
            try await newUserFriendRef.setData([
                "id": friendInfo.uid,
                "name": friendInfo.name,
                "email": friendInfo.email,
            ])
            
            //相手側のフレンドに追加
            let newTargetFriendRef = targetFriendRef.document(uid)
            try await newTargetFriendRef.setData([
                "id": userInfo.uid,
                "name": userInfo.name,
                "email": userInfo.email,
            ])
            
            print("フレンドの追加に成功しました")
            
        }catch{
            print("フレンドの追加に失敗しました： \(error)")
        }
        
    }
    
    //フレンド申請
    func sendFriendRequest(uid:String,friendUid:String)async -> Void{
        if(uid == "" || friendUid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        let userInfo = await fetchUserInfo(uid: uid)
        let friendInfo = await fetchUserInfo(uid: friendUid)
        
        let senderRequestRef = db.collection("user").document(uid).collection("friendRequest")
        let recievereRequestRef = db.collection("user").document(friendUid).collection("friendRequest")
        
        do {
            let newSenderDocRef = senderRequestRef.document(friendUid)
            try await newSenderDocRef.setData([
                "id":friendInfo.uid,
                "name":friendInfo.name,
                "email":friendInfo.email,
                "isRecieve":false
            ])
            
            let newRecieverDocRef = recievereRequestRef.document(uid)
            try await newRecieverDocRef.setData([
                "id":userInfo.uid,
                "name":userInfo.name,
                "email":userInfo.email,
                "isRecieve":true
            ])
            print("フレンド申請しました")
        }catch{
            print("フレンド申請に失敗しました: \(error)")
        }
    }
    
//MARK: firebaseのデータの変更・削除
    
    //フレンドの削除
    func deleteFriend(uid: String, friendUid: String)async -> Void{
        if(uid == "" || friendUid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        let userFriendRef = db.collection("user").document(uid).collection("friends")
        let targetFriendRef = db.collection("user").document(friendUid).collection("friends")
        do{
            //自分側のフレンド欄から削除
            let userFriendSnapshot = try await userFriendRef.getDocuments()
            for document in userFriendSnapshot.documents{
                let documentId = document.documentID
                let data = document.data()
                
                if let id = data["id"] as? String{
                    if id == friendUid{
                        try await userFriendRef.document(documentId).delete()
                    }
                }else{
                    print("document \(documentId) に \(friendUid) が存在しません")
                }
            }
            
            //相手側のフレンド欄から削除
            let targetFriendSnapshot = try await targetFriendRef.getDocuments()
            for document in targetFriendSnapshot.documents{
                let documentId = document.documentID
                let data = document.data()
                
                if let id = data["id"] as? String{
                    if id == uid{
                        try await targetFriendRef.document(documentId).delete()
                    }
                }else{
                    print("document \(documentId) に \(uid) が存在しません")
                }
            }
            print("フレンドの削除に成功しました")
        }catch{
            print("フレンドの削除に失敗しました: \(error)")
        }
    }
    
    //フレンドリクエストの削除
    func deleteFriendRequest(uid: String, friendUid: String)async -> Void{
        if(uid == "" || friendUid == ""){
            print("uidまたはfriendUidが空です")
            return
        }
        let userFriendRequestRef = db.collection("user").document(uid).collection("friendRequest")
        let targetFriendRequestRef = db.collection("user").document(friendUid).collection("friendRequest")
        do{
            //自分側のリクエストを削除
            let userFriendRequestSnapshot = try await userFriendRequestRef.getDocuments()
            for document in userFriendRequestSnapshot.documents{
                let documentId = document.documentID
                let data = document.data()
                
                if let id = data["id"] as? String{
                    if id == friendUid{
                        try await userFriendRequestRef.document(documentId).delete()
                    }
                }else{
                    print("document \(documentId) に \(friendUid) が存在しません")
                }
            }
            
            //相手側のリクエストを削除
            let targetFriendRequestSnapshot = try await targetFriendRequestRef.getDocuments()
            for document in targetFriendRequestSnapshot.documents{
                let documentId = document.documentID
                let data = document.data()
                
                if let id = data["id"] as? String{
                    if id == uid{
                        try await targetFriendRequestRef.document(documentId).delete()
                    }
                }else{
                    print("document \(documentId) に \(uid) が存在しません")
                }
            }
            print("フレンドリクエストの削除に成功しました")
        }catch{
            print("フレンドリクエストの削除に失敗しました: \(error)")
        }
    }
    
    //お気に入りの削除
    func deleteFavoritePokemon(uid: String, pokemonId: Int)async -> Void{
        if(uid == ""){
            print("uidが空です")
            return
        }
        let favoritePokemonRef = db.collection("user").document(uid).collection("favorite")
        do{
            let favoriteSnapshot = try await favoritePokemonRef.getDocuments()
            for document in favoriteSnapshot.documents{
                let documentId = document.documentID
                let data = document.data()
                
                if let favoritePokemonId = data["id"] as? Int{
                    if favoritePokemonId == pokemonId{
                        try await favoritePokemonRef.document(documentId).delete()
                    }
                }
            }
            print("お気に入りの削除に成功しました")
        }catch{
            print("お気に入りの削除に失敗しました: \(error)")
        }
        
    }
    
    //ユーザー情報を全削除
    func deleteAllUserData(uid: String)async -> Void{
        if(uid == ""){
            print("uidが空です")
            return
        }
        let userDocRef = db.collection("user").document(uid)
        
        //フレンドの全削除
        let friendRef = userDocRef.collection("friends")
        do{
            let friendSnapshot = try await friendRef.getDocuments()
            for document in friendSnapshot.documents{
                let documentId = document.documentID
                try await friendRef.document(documentId).delete()
            }
        }catch{
            print("フレンドの全削除に失敗しました: \(error)")
        }
        
        //フレンドリクエストの全削除
        let friendRequestRef = userDocRef.collection("friendRequest")
        do{
            let friendRequestSnapshot = try await friendRequestRef.getDocuments()
            for document in friendRequestSnapshot.documents{
                let documentId = document.documentID
                try await friendRequestRef.document(documentId).delete()
            }
        }catch{
            print("フレンドリクエストの全削除に失敗しました: \(error)")
        }
        
        //お気に入りの全削除
        let favoritePokemonRef = userDocRef.collection("favorite")
        do{
            let favoritePokemonSnapshot = try await favoritePokemonRef.getDocuments()
            for document in favoritePokemonSnapshot.documents{
                let documentId = document.documentID
                try await favoritePokemonRef.document(documentId).delete()
            }
        }catch{
            print("お気に入りの全削除に失敗しました: \(error)")
        }
        
        //ユーザー情報の削除
        do{
            try await userDocRef.delete()
        }catch{
            print("ユーザー情報の削除に失敗しました: \(error)")
        }
        
    }
    
}
