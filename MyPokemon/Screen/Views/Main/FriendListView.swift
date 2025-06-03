//
//  FriendListView.swift
//  MyPokemon

import SwiftUI

struct FriendListView: View {
    @EnvironmentObject var authService:AuthService
    let firebaseService = FirebaseService()
    
    @State var friendsList:[UserInfo] = []
    @State private var searchID: String = ""
    @State private var showAddFriendView: Bool = false //検索バーの表示
    @State private var matchedUser: UserInfo? = nil //検索に一致したユーザー
    @State private var errorMessage: String = ""
    @State private var buttonMessage: String = ""
    
    @State private var uid = ""
    @State private var userFriendRequest: [FriendRequestInfo] = []
    @State private var isAlreadyRequested: Bool = false
    @State private var hasReceivedRequest:Bool = false
    
    @State var isFriendProfilePresented: Bool = false
    @State private var friendInfo: UserInfo = .init(uid: "", name: "", email: "")
    
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
                                matchedUser = nil
                                searchID = ""
                                errorMessage = ""
                                
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
                            
                            TextField("IDを入力", text: $searchID)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(8)
                            
                            Button(action: {
                                Task{
                                    matchedUser = nil
                                    errorMessage = ""
                                    isAlreadyRequested = false
                                    if searchID == uid {
                                        errorMessage = "あなたのIDです"
                                    }
                                    
                                    if let result = await firebaseService.fetchUserInfo(uid: searchID) {
                                        matchedUser = result
                                    } else {
                                        errorMessage = "ユーザーが存在しません"
                                        return
                                    }
                                    
                                    //既に申請していないかのチェック
                                    for user in userFriendRequest {
                                        if user.uid == searchID && user.isRecieved == false{
                                            isAlreadyRequested = true
                                            buttonMessage = "申請済み"
                                        }
                                    }
                                    for friend in friendsList {
                                        if friend.uid == searchID{
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
                                    .opacity(searchID.isEmpty ? 0.6 : 1)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .disabled(searchID.isEmpty)
                            
                        }
                        .padding(.leading,16)
                        .padding(.trailing,2)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.bottom, 8)
                        
                        if let matchedUser = matchedUser, errorMessage == "" {
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
                                        fontColor: Color.white,
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
                                                buttonMessage = "申請済み"
                                                isAlreadyRequested = true
                                                
                                                await firebaseService.sendFriendRequest(
                                                    uid: uid,
                                                    friendUid: matchedUser.uid
                                                )
                                                
                                                //ボタンを押した後のリクエストの更新
                                                userFriendRequest = await firebaseService.fetchFriendRequestList(uid: uid)
                                            }
                                        }
                                    )
                                }
                                
                            }else if errorMessage != "" {
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
                    if hasReceivedRequest{
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
                                            hasReceivedRequest = firebaseService.hasReceievedFriendRequest(requests: userFriendRequest)
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
                                                friendUid: request.uid
                                            )
                                            
                                            await firebaseService.deleteFriendRequest(
                                                uid: uid,
                                                friendUid: request.uid
                                            )

                                            userFriendRequest = await firebaseService.fetchFriendRequestList(uid: uid)
                                            friendsList = await firebaseService.fetchFriendsList(uid: uid)
                                            hasReceivedRequest = firebaseService.hasReceievedFriendRequest(requests: userFriendRequest)
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
                                .onTapGesture {
                                    friendInfo = friend
                                    isFriendProfilePresented = true
                                }
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
                hasReceivedRequest = firebaseService.hasReceievedFriendRequest(requests: userFriendRequest)
            }
        }
        .fullScreenCover(isPresented: $isFriendProfilePresented){
            FriendProfileView(isFriendProfilePresented: $isFriendProfilePresented, friendInfo: $friendInfo)
        }
    }
}

#Preview {
    FriendListView()
        .environmentObject(AuthService())
}
