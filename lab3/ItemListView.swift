//
//  ItemListView.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import SwiftUI
import Firebase

struct ItemListView: View {
    @State private var items: [Item] = []
    @State private var search: String = ""
    @State private var myComplexity:String = "all"
    @State private var moneyUp:Int = 0// 0- none 1 - true 2-false
    @State private var ratingUp:Int = 0// 0- none 1 - true 2-false
    @State var showingSheet = false
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                itemListAppBar()
                getSearchPannel()
                getItemList()
            }.navigationBarHidden(true)
        }.sheet(isPresented: $showingSheet, content: filterSheet)
    }
        
    func getItemList() -> some View {
        return
        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
        .edgesIgnoringSafeArea(.vertical).overlay(
            List(items) { item in
                if itemMatchFilters(item: item){
                ItemInList(item: item).listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .background(.clear)
                        .foregroundColor(.white)
                        .padding(
                            EdgeInsets(
                                top: 10,
                                leading: 0,
                                bottom: 10,
                                trailing: 0
                            )
                        )
                ).listRowSeparator(.hidden)
                    
                }
            }.onAppear {
                UITableView.appearance().backgroundColor = .clear
                readDataFromFirebase()
            }
        )
    }
    
    func readDataFromFirebase() {
            let ref = Database.database().reference().child("items")
            
            ref.observe(.value) { snapshot in
                var newItems: [Item] = []
                
                for case let child as DataSnapshot in snapshot.children {
                    if let objectData = child.value as? [String: Any]{
                        let object = Item.fromDictionary(objectData)
                        newItems.append(object!)
                    }
                }
                
                self.items = newItems
            }
        }
    func getSearchPannel() -> some View {
        HStack {
            TextField("Search", text: $search)
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(red: 163/255, green: 97/255, blue: 0/255))
                            .padding(10)
                        
                    }
                ).overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 163/255, green: 97/255, blue: 0/255), lineWidth: 1))
            
            Button(action: {
                showingSheet = true
            }) {
                Image(systemName: "line.horizontal.3.decrease")
                    .foregroundColor(Color(red: 163/255, green: 97/255, blue: 0/255))
                    .font(.title)
            }
        }
        .padding()
    }
    func itemListAppBar() -> some View {
        return
        ZStack {
                Rectangle()
                            .frame(height: 80)
                            .foregroundColor(.orange)
                            .padding(.top,20)
                        .cornerRadius(20)
                        .padding(.top, -20)
                        
                HStack{
                    Spacer().frame(width: 10)
                    Button(action: {
                        do{
                            try Auth.auth().signOut()
                            
                        } catch let signOutError{
                            
                        }
                                        }) {
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                    Spacer().frame(width: 40)
                    Spacer()
                    Text("Items")
                                   .font(.title)
                                   .foregroundColor(.white)
                                   .fontWeight(.bold)
                                   .padding(.top, 10)
                    Spacer()
                    
                    NavigationLink(destination: FavouritesListView()) {
                        Image(systemName: "heart.fill")
                                                .foregroundColor(.white)
                                                .font(.title)
                    }
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.fill")
                                                .foregroundColor(.white)
                                                .font(.title)
                    }
                    Spacer().frame(width: 10)
                }
            }
        }
    

    func itemMatchFilters(item: Item)-> Bool {
        var searchRes:Bool = true
        if !search.isEmpty
            {searchRes = item.name.contains(search)}
        if myComplexity != "all"
            {searchRes = searchRes && (item.diff == myComplexity)}
        return searchRes
    }
    
    func filterSheet() -> some View {
        return
        VStack {
            Text("Money")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(10)
                    .frame(width: 200)
                
            HStack {
                
                Picker(selection: $moneyUp, label: Text("Money")){
                    Text("Up").tag(1).font(.system(size: 25))
                    Text("Down").tag(2).font(.system(size: 25))
                    Text("None").tag(0).font(.system(size: 25))
                }.pickerStyle(.segmented)
                        .padding(10)
                }
                .frame(height: 50)
            
            Text("Complexity")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(10)
                    .frame(width: 200)
                
            HStack {
                
                Picker(selection: $myComplexity, label: Text("Complexity")){
                    Text("easy").tag("easy").font(.system(size: 25))
                    Text("medium").tag("medium").font(.system(size: 25))
                    Text("hard").tag("hard").font(.system(size: 25))
                    Text("all").tag("all").font(.system(size: 25))
                }.pickerStyle(.segmented)
                        .padding(10)
                }
                .frame(height: 50)
            Text("Rating")
                    .foregroundColor(.black)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(10)
                    .frame(width: 200)
                
            HStack {
                
                Picker(selection: $ratingUp, label: Text("Rating")){
                    Text("Up").tag(1).font(.system(size: 25))
                    Text("Down").tag(2).font(.system(size: 25))
                    Text("None").tag(0).font(.system(size: 25))
                }.pickerStyle(.segmented)
                        .padding(10)
                }
                .frame(height: 50)
            
            HStack{
                Button("Apply", action:{
                    sortList()
                    showingSheet = false}
                )
            }
        }
        .interactiveDismissDisabled()        
    }
    func sortList(){
        if moneyUp != 0{
            if moneyUp == 1{
                items.sort{$0.price < $1.price}
            }
            else{
                items.sort{$0.price > $1.price}
            }
        }
        if ratingUp != 0{
            if ratingUp == 1{
                items.sort{$0.avgRating! < $1.avgRating!}
            }
            else{
                items.sort{$0.avgRating! > $1.avgRating!}
            }
        }
    }
}
