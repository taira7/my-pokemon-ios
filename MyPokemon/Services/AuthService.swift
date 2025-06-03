//
//  AuthState.swift
//  MyPokemon

import SwiftUI
import FirebaseAuth

final class AuthService:ObservableObject{
    @Published var isAuth: Bool = false
    @Published var currentUser: User? = nil
    let firebaseService = FirebaseService()
    
    init(){
        observeAuthChanges()
    }
    
    func signUp(name:String, email: String, password: String) -> Void{
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
//            print("authResult:",authResult)
            
            if let error = error{
                print("signUp error: \(error)")
            }
            
            if let userData = authResult?.user{
                print("signUp success: \(userData)")
                Task{
                    await self.firebaseService.addUser(uid: userData.uid, name: name, email: email)
                }
                self.signIn(email: email, password: password)
            }
        }
    }
    
    func signIn(email: String, password: String) -> Void{
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
            if let error = error{
                Task{
                    await self?.signOut()
                }
                print("signIn error: \(error)")
            }
            
            if let userData = authResult?.user{
                print("signIn success: \(userData)")
            }
        }
    }
    
    func signOut()async -> Void{
        do {
            try Auth.auth().signOut()
            print("signOut success:")
            DispatchQueue.main.async {
                self.isAuth = false
            }
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
                    print("ユーザーデータの削除に成功しました")
                }
            }
        }
    }
    
    private func observeAuthChanges() {
            _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            //weakではoptional型になる
//            print("observedAuthChanges:",user)
                
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
