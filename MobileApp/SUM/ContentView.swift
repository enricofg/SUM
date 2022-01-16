//
//  ContentView.swift
//  SUM
//
//  Created by Luís Sousa on 04/01/2022.
//

import SwiftUI

struct ContentView: View {
    init(){
        UITabBar.appearance().barTintColor = .systemBackground
    }
    var body: some View {
        TabView{
            Text("First")
                .tabItem{
                    Image(systemName: "person")
                    Text("First")
                }
            Text("Second")
                .tabItem{
                    Image(systemName: "gear")
                    Text("Second")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
