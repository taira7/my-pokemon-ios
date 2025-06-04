//
//  ProfileCard.swift
//  MyPokemon

import SwiftUI

struct ProfileCard: View {
    let width: CGFloat
    let height: CGFloat
    let user: UserInfo
    let isShowEmail: Bool
    let isShowButton: Bool
    
    var body: some View {
        VStack{
            HStack(spacing: 16){
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(.blue)
                    .padding(.leading,12)
                
                VStack(spacing: 12) {
                    
                    Text(user.name)
                        .font(.title)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                    if isShowEmail {
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .lineLimit(1)
                    }
                    
                    
                    HStack{
                        Text(user.uid)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .lineLimit(1)
                        
                        if isShowButton {
                            Button(action: {
                                UIPasteboard.general.string = user.uid
                            }){
                                ZStack{
                                    Circle()
                                        .stroke(Color.blue)
                                        .shadow(radius: 1)
                                        .frame(width: 28,height: 28)
                                    Image(systemName:"document.on.document")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(Color.blue)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity,alignment: .leading)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(
            width: width,
            height: height
        )
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 6)
    }
}
