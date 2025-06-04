//
//  AuthState.swift
//  MyPokemon

import SwiftUI
import FirebaseAuth

final class AuthService:ObservableObject{
    @Published var isAuth: Bool = false
    @Published var currentUser: User? = nil
    let firebaseService = FirebaseService()
    
    //Auth.auth()の処理関連の返り値がVoidなので，エラーメッセージをここで管理する
    @Published var errorMessage: String?
    
    init(){
        observeAuthChanges()
    }
    
    //withCheckedContinuation -> クロージャで行う非同期関数をasync/awaitに置き換える
    //Auth.auth()の処理がerrorMessageのalert表示に間に合わないのでwithCheckedContinuationを追加
    
    func signUp(name:String, email: String, password: String) async -> Bool{
        do{
            let authResult:AuthDataResult = try await withCheckedThrowingContinuation{ continuation in
                Auth.auth().createUser(withEmail: email, password: password){ result, error in
                    if let error = error {
                        print("sinUp error: \(error)")
                        continuation.resume(throwing: error)
                    }else if let result = result {
                        continuation.resume(returning: result)
                    }
                }
            }
            await self.firebaseService.addUser(uid: authResult.user.uid, name: name, email: email)
            return await self.signIn(email: email, password: password)
            
        }catch{
            
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }
            
            return false
        }
    }
    
    func signIn(email: String, password: String) async -> Bool{
        do{
            let _ :AuthDataResult = try await withCheckedThrowingContinuation{ continuation in
                Auth.auth().signIn(withEmail: email, password: password){ result, error in
                    if let error = error {
                        print("signIn error: \(error)")
                        continuation.resume(throwing: error)
                    }else if let result = result {
                        continuation.resume(returning: result)
                    }
                }
            }
            return true
        }catch{
            
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
            }

            await self.signOut()
            return false
        }
    }
    
    func signOut()async -> Void{
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteUser()async -> Void{
        Auth.auth().currentUser?.delete{ error in
            if let error = error {
                print(error)
            }else{
                Task{
                    await self.firebaseService.deleteAllUserData(uid: self.currentUser?.uid ?? "")
                    await self.signOut()
                }
            }
        }
    }
    
    private func observeAuthChanges() {
            _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            //weakではoptional型になる
                DispatchQueue.main.async {
                    self?.currentUser = user
                    if user != nil {
                        self?.isAuth = true
                    }else{
                        self?.isAuth = false
                    }
                }
            
        }
    }
    
}
