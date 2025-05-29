//
//  FriendListView.swift
//  MyPokemon

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject var authService:AuthService
    let firebaseService = FirebaseService()
    
    @State var friendsList:[UserInfo] = []
    @State private var searchText: String = ""
    @State private var showAddFriendView: Bool = false
    @State private var matchedUser: UserInfo = .init(uid: "", name: "", email: "")
    @State private var errorMessage: String = ""
    @State private var buttonMessage: String = ""
    
    @State private var uid = ""
    @State private var userFriendRequest: [FriendRequestInfo] = []
    @State private var isAlreadyRequested: Bool = false
    
    var body: some View {
        
            GeometryReader{ geometry in
                VStack{
                    
                    HStack {
                        Text("フレンド一覧")
                            .font(.title2)
                            .fontWeight(.bold)
                                        
                        Spacer()
                                        
                        Button(action: {
                            
                            if showAddFriendView == true {
                                //入力部分を初期化
                                matchedUser = .init(uid: "", name: "", email: "")
                                searchText = ""
                                showAddFriendView = false
                            }else{
                                showAddFriendView = true
                            }
                            
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(showAddFriendView ? Color.gray : Color.blue, lineWidth: 1)
                                    .frame(width: 28, height: 28)
                                    .shadow(radius: 1)
                                                
                                Image(systemName: "person.badge.plus")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(showAddFriendView ? Color.gray : Color.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    Divider()
                    
                    //MARK: 検索機能
                    if showAddFriendView {
                        Text("ユーザーを探す")
                            .font(.title3)
                        
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("IDを入力", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                            
                            Button(action: {
                                print("検索ボタンが押されました：\(searchText)")
                                Task{
                                    errorMessage = ""
                                    isAlreadyRequested = false
                                    if searchText == uid {
                                        errorMessage = "あなたのIDです"
                                    }
                                    
                                    matchedUser =  await firebaseService.fetchUserInfo(uid: searchText)
                                    
                                    if matchedUser.name == "ユーザーが存在しません" || matchedUser.name == "取得できません" {
                                        errorMessage = "ユーザーが存在しません"
                                        return
                                    }
                                    
                                    //既に申請していないかのチェック
                                    for user in userFriendRequest {
                                        if user.uid == searchText && user.isRecieved == false{
                                            isAlreadyRequested = true
                                            buttonMessage = "申請済み"
                                            
                                        }
                                    }
                                    for friend in friendsList {
                                        if friend.uid == searchText{
                                            isAlreadyRequested = true
                                            buttonMessage = "フレンド登録済み"
                                        }
                                    }
                                    
                                    
                                }
                            }) {
                                Text("検索")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .opacity(searchText.isEmpty ? 0.6 : 0.8)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(searchText.isEmpty)
                            
                        }
                        .padding(.leading,16)
                        .padding(.trailing,2)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.bottom, 8)
                        
                        if matchedUser.name != "" && errorMessage == "" {
                            ProfileCard(
                                width: geometry.size.width * 0.85,
                                height: geometry.size.height * 0.2,
                                user: matchedUser,
                                isShowEmail: false,
                                isShowButton: false
                            )
                            
                            if isAlreadyRequested {
                                CustomWideButton(
                                    label: buttonMessage,
                                    fontColor: Color.black,
                                    backgroundColor: Color.gray,
                                    width: geometry.size.width * 0.8,
                                    height: geometry.size.height * 0.08,
                                    isDisabled: true,
                                    action: {}
                                )
                            }else{
                                CustomWideButton(
                                    label: "フレンド申請する",
                                    fontColor: Color.white,
                                    backgroundColor: Color.blue,
                                    width: geometry.size.width * 0.8,
                                    height: geometry.size.height * 0.08,
                                    isDisabled: false,
                                    action: {
                                        Task{
                                            await firebaseService.sendFriendRequest(
                                                uid: uid,
                                                friendUid: matchedUser.uid
                                            )
                                            isAlreadyRequested = true
                                        }
                                    }
                                )
                            }
                            
                        }else if matchedUser.name != "" && errorMessage != "" {
                            HStack{
                                Image(systemName: "info.circle")
                                
                                Text(errorMessage)
                                    .font(.headline)
                            }
                            .foregroundColor(.red)
                            .padding()
                        }
                        
                        Divider()
                    }
                    
                    //MARK: 承認待ちの確認
                    if !userFriendRequest.isEmpty{
                        Text("承認待ち")
                            .font(.title3)
                        
                        ForEach(userFriendRequest,id: \.uid) { request in
                            if request.isRecieved  == true {
                                ProfileCard(
                                    width: geometry.size.width * 0.85,
                                    height: geometry.size.height * 0.2,
                                    user: UserInfo(uid: request.uid, name: request.name, email: request.email),
                                    isShowEmail: false,
                                    isShowButton: false
                                )
                                
                                HStack(spacing: 20){
                                    Button(action: {
                                        Task{
                                            await firebaseService.deleteFriendRequest(
                                                uid: uid,
                                                friendUid: request.uid
                                            )
                                            userFriendRequest = await firebaseService.fetchFriendRequestList(uid: uid)
                                            friendsList = await firebaseService.fetchFriendsList(uid: uid)
                                        }
                                    }){
                                        Text("拒否")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 24)
                                            .background(Color.red)
                                            .cornerRadius(10)
                                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    
                                    
                                    Button(action: {
                                        Task{
                                            await firebaseService.addFriend(
                                                uid: uid ,
                                                friendUid: request.uid)
                                            
                                            await firebaseService.deleteFriendRequest(
                                                uid: uid,
                                                friendUid: request.uid
                                            )
                                            
                                            userFriendRequest = await firebaseService.fetchFriendRequestList(uid: uid)
                                            
                                            friendsList = await firebaseService.fetchFriendsList(uid: uid)
                                        }
                                        
                                    }){
                                        Text("承認")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 24)
                                            .background(Color.blue)
                                            .cornerRadius(10)
                                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                }
                                
                            }
                        }
                        Divider()
                    }
                    
                    //MARK: フレンドリストの表示
                    if !friendsList.isEmpty{
                        List{
                            ForEach(friendsList,id:\.uid){ friend in
                                ProfileCard(
                                    width: geometry.size.width * 0.85,
                                    height: geometry.size.height * 0.2,
                                    user: friend,
                                    isShowEmail: false,
                                    isShowButton: true
                                )
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .contentShape(Rectangle()) // タップ領域の指定
                            }
                            .listRowSeparator(.hidden)
                        }
                    }else{
                        Text("フレンドがいません")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                }
            }
        
        .navigationBarSetting(title: "フレンド", isVisible: true)
        .onAppear(){
            Task{
                uid = authService.currentUser?.uid ?? ""
                friendsList = await firebaseService.fetchFriendsList(uid: uid)
                userFriendRequest = await firebaseService.fetchFriendRequestList(uid: uid)
            }
        }
    }
}

#Preview {
    FriendListView()
}
