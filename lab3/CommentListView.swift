//
//  CommentListView.swift
//  lab3
//
//  Created by Viktoriya on 28.04.24.
//

import SwiftUI
import Firebase

struct CommentListView: View {
    let item: Item
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    @State private var comments: [Comment] = []
    @State private var comment: String = ""
    @State private var username: String = ""
    init(item:Item) {
            self.item = item
        }
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                commentListAppBar()
                getCommentList()
                commentSendBar()
            }.navigationBarHidden(true)
        }.navigationBarHidden(true)
            .onAppear{
                dataService.getUser(userId: authService.currentUser!) { value in
                    DispatchQueue.main.async {
                        self.username = value!.name + " " + value!.surname
                    }
                }
            }
    }
        
    func getCommentList() -> some View {
        return
        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
        .edgesIgnoringSafeArea(.vertical).overlay(
            
            List(comments) { comment in
                CommentInList(comment: comment).listRowBackground(
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
                )
                .listRowSeparator(.hidden)
                
            }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    readDataFromFirebase()
                }
        )
    }
    
    func readDataFromFirebase() {
        let ref = Database.database().reference().child("items").child(item.id).child("comments")
            
            ref.observe(.value) { snapshot in
                var newComments: [Comment] = []
                
                for case let child as DataSnapshot in snapshot.children {
                    if let objectData = child.value as? [String: Any]{
                        let object = Comment.fromDictionary(objectData)
                        newComments.append(object)
                    }
                }
                
                self.comments = newComments
            }
        }
    func commentListAppBar() -> some View {
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
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                                            Image(systemName: "arrow.left")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                    Spacer()
                    Text("Comments")
                                   .font(.title)
                                   .foregroundColor(.white)
                                   .fontWeight(.bold)
                                   .padding(.top, 10)
                    Spacer()
                    Spacer().frame(width: 50)
                }
            }
    }
    
    func commentSendBar() -> some View {
        return
        ZStack {
            Rectangle()
                        .frame(height: 100)
                        .foregroundColor(.orange)
            HStack(alignment: .center) {
            TextField("Your comment", text: $comment)
                    .padding()
                    .frame(width: 320, height: 50)
                    .background(Color.white)
                    .cornerRadius(20)
                    
                    Button(action: {
                        sendComment()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 35))
                    }
                    .frame(width: 50, height: 50)
                    .background(Color.orange)
                    .cornerRadius(20)
            }
        }
        
    }
    func sendComment(){
        if !comment.isEmpty {
            let key = dataService.getNextCommKey(itemId: item.id)
            let comm = Comment(id: key!, itemId: item.id, userId: authService.currentUser!, userName: username, comment: comment, timestamp: String(NSDate().timeIntervalSince1970))
            dataService.saveComment(comment: comm, itemId: item.id, key: key!)
            dataService.saveComment(comment: comm, itemId: item.id, key:key!)
            comment = ""
        }
    }
}
