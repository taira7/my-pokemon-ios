//
//  AuthState.swift
//  MyPokemon

import SwiftUI
import FirebaseAuth

final class AuthService:ObservableObject{
    @Published var isAuth: Bool = true
    @Published var currentUser: User? = nil
    
    init(){
        observeAuthChanges()
    }
    
    func signUp(name:String, email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password){ authResult, error in
            print("authResult:",authResult)
            
            if let error = error{
                print("signUp error: \(error)")
            }
            
            if let userData = authResult?.user{
                print("signUp success: \(userData)")
                self.signIn(email: email, password: password)
                self.isAuth = true
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
                self?.isAuth = true
            }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            self.isAuth = false
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    private func observeAuthChanges() {
            _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            //weakではoptional型になる
            print("observedAuthChanges:",user)
            self?.currentUser = user
            if user != nil {
                self?.isAuth = true
            }else{
                self?.isAuth = false
            }
            
        }
    }
    
}
