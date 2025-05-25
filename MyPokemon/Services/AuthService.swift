//
//  AuthState.swift
//  MyPokemon

import SwiftUI
import FirebaseAuth

//シングルトンに変更する
class AuthService: ObservableObject{
    @Published var isAuth: Bool = false
    
    static let shared = AuthService()
    
    private var currentUser: User?
    
    init(){}
    
//    var currentUser: User?{
//        return Auth.auth().currentUser
//    }
    
    func signUp(name:String, email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            if let error = error{
                print("signUp error: \(error)")
            }
            
            if let userData = authResult?.user{
                print("signUp success: \(userData)")
                self.signIn(email: email, password: password)
            }
        }
    }
    
    func signIn(email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password){ [weak self] authResult, error in
                if let error = error{
                print("signIn error: \(error)")
            }
            
            if let userData = authResult?.user{
                print("signIn success: \(userData)")
                self?.isAuth = false
            }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    private func observeAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
        }
    }
    
}
