//
//  SignUpView.swift
//  MyPokemon

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authState: AuthState
    @Binding var isSignUpPresented: Bool
    @State var name: String = ""
    @State var email: String = ""
    @State var password: String = ""

    let gradient = Gradient(stops: [
        .init(color: Color(red: 1.0, green: 0.6, blue: 0.2), location: 0.0),  // 橙（オレンジ）
        .init(color: Color(red: 1.0, green: 0.4, blue: 0.4), location: 1.0)   // 明るい赤（コーラル寄り）
    ])
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack{
                Text("アカウント登録")
                    .font(.system(size: 32, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 3, y: 3)
                
                TextField(
                    text: $name,
                    prompt: Text("名前")
                ){
                    
                }
                .font(.system(size: 20))
                .padding(12)
                .padding(.leading,8)
                .background(Color.white)
                .border(Color.white.opacity(0.6), width: 2)
                .cornerRadius(10)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 3, y: 3)
                
                
                TextField(
                    text: $email,
                    prompt: Text("メールアドレス")
                ){
                    
                }
                .font(.system(size: 20))
                .padding(12)
                .padding(.leading,8)
                .background(Color.white)
                .border(Color.white.opacity(0.6), width: 2)
                .cornerRadius(10)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 3, y: 3)
                
                
                SecureField(
                    text: $password,
                    prompt: Text("パスワード")
                ) {
                }
                .font(.system(size: 20))
                .padding(12)
                .padding(.leading,8)
                .background(Color.white)
                .border(Color.white.opacity(0.6), width: 2)
                .cornerRadius(10)
                .padding(.horizontal, 24)
                .padding(.bottom, 80)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 3, y: 3)
                
                CustomWideButton(label: "登録する", fontColor: Color.blue, width: 300, height: 36, action: {
                    isSignUpPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        authState.isAuth = true
                    }
                })
            }
        }
    }
}

#Preview {
    @Previewable @State var isSignUpPresented: Bool = true
    SignUpView(isSignUpPresented: $isSignUpPresented)
        .environmentObject(AuthState())
}
