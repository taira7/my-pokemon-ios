//
//  SignView.swift
//  SclaNote

import SwiftUI

struct SignView: View {
    
//    @EnvironmentObject var authState: AuthState
    @State var isSignInPresented: Bool = false
    @State var isSignUpPresented: Bool = false
    
    let gradient = Gradient(stops: [.init(color: Color.cyan, location: 0.0), .init(color: Color.purple, location: 1.0)])
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                    .ignoresSafeArea()
                
                VStack{
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundColor(Color.white)
                        .padding(.bottom,164)
                    
                    
                    ActionWideButton(
                        label: "ログインする", fontColor: Color.blue, width: geometry.size.width * 0.9, height: geometry.size.height * 0.07, action: {
                            print("ログイン")
                            isSignInPresented.toggle()
                            
                        }
                    )
                    
                    Button(action:{
                        isSignUpPresented.toggle()
                    },label: {
                        Text("アカウントを作成する")
                            .font(.headline)
                            .foregroundColor(Color.white)
                    })
                    .padding(.top,28)
                }
            }
            .sheet(isPresented: $isSignInPresented){
                SignInView(isSignInPresented: $isSignInPresented)
            }
            .sheet(isPresented: $isSignUpPresented){
                SignUpView(isSignUpPresented: $isSignUpPresented)
            }
        }
    }
}

#Preview {
    SignView()
}
