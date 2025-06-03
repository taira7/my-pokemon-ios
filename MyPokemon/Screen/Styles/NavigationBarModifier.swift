//
//  NavigationBarModifier.swift
//  MyPokemon

import SwiftUI


//MARK: NavigationBar全体の表示
struct NavigationBarOptions{
    var title: String?
    let isVisible: Bool
}

private struct NavigationBarModifier: ViewModifier{
    var options: NavigationBarOptions
    init(options: NavigationBarOptions) {
        self.options = options
        setAppearance()
    }
    
    func body(content: Content) -> some View {
        let title = options.title ?? ""
        let isShowNavigationBar = options.isVisible
        
        content
            .navigationBarTitleDisplayMode(.inline)//タイトルの表示形式
            .navigationTitle(title)
            .navigationBarHidden(isShowNavigationBar ? false : true)
    }
    
    private func setAppearance(){
        //UIKitのオブジェクト
        let appearance = UINavigationBarAppearance()
        
        //背景色の設定
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "ThemeColor")
        
        //下線の色
        appearance.shadowColor = .clear
        
        //タイトルの色
        appearance.titleTextAttributes = [.foregroundColor:UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor:UIColor.white]
        
        //設定を適応させる
        //スクロールが一番上以外のとき
        UINavigationBar.appearance().standardAppearance = appearance
        //スクロールが一番上のとき
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

extension View {
    func navigationBarSetting(title:String,isVisible: Bool) -> some View {
        modifier(NavigationBarModifier(options: .init(title: title, isVisible: isVisible)))
    }
}

//MARK: NavigationBarのアイコンの設定
struct NavigationBarIconOptions{
    let name: String
    let color: Color
    let isEnable: Bool
    let placement: ToolbarItemPlacement
    let action: () -> Void
}

private struct NavigationBarIconModifier: ViewModifier {
    var options: NavigationBarIconOptions
    init(options: NavigationBarIconOptions) {
        self.options = options
    }
    func body(content: Content) -> some View {
        content
            .toolbar{
                ToolbarItem(placement:options.placement){
                    Button(action: options.action,label: {
                        Image(systemName: options.name)
                            .foregroundColor(options.isEnable ? .white : .gray)})
                            .disabled(!options.isEnable)
                }
            }
    }
}

extension View {
    func NavigationBarIconSetting(name:String,color:Color,isEnable:Bool,placement:ToolbarItemPlacement, action:@escaping ()->Void)-> some View {
        modifier(NavigationBarIconModifier(options: .init(name: name, color: color,isEnable: isEnable, placement: placement,action: action)))
    }
}
