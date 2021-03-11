//
//  ClubView.swift
//  Helselia
//
//  Created by evelyn on 2020-11-27.
//
// SNOWFLAKES
// Structure: TIMESTAMP MESSAGE USER CHANNEL
//
// Root Number
// 999999999999
// aka 12x the number 9


import SwiftUI

// styles and structs and vars

var InputMsgIndex: Int = 0
var root: Int = 999999999999
let messages = NetworkHandling()
let net = NetworkHandling()
let parser = parseMessages()

struct CoolButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? CGFloat(0.85) : 1.0)
            .rotationEffect(.degrees(configuration.isPressed ? 0.0 : 0))
            .blur(radius: configuration.isPressed ? CGFloat(0.0) : 0)
            .animation(Animation.spring(response: 0.35, dampingFraction: 0.35, blendDuration: 1))
            .padding(.bottom, 3)
    }
}

// button style extension

extension Button {
    func coolButtonStyle() -> some View {
        self.buttonStyle(CoolButtonStyle())
    }
}

extension Dictionary {
    mutating func switchKey(fromKey: Key, toKey: Key) {
        if let entry = removeValue(forKey: fromKey) {
            self[toKey] = entry
        }
    }
}

// the messaging view concept

struct ClubView: View {
    
    
//    main variables for chat, will be migrated to backendClient later
    
    @State var chatTextFieldContents: String = ""
    @State var username = backendUsername
    @State public var ChannelKey = 1
    
//    message storing vars
    
    @State var MaxChannelNumber = 0
    @State var userID = 999999999999
    @State var channelID = 999999999999
    @State var messageArray = []
    @State var usernameArray = []
//    actual view begins here
    
    func refresh() {
        messageArray = parser.getArray(forKey: "content", messageDictionary: net.request(url: "https://constanze.live/api/v1/channels/148502836349636615/messages", token: token, Cookie: "__cfduid=d7ec9d856babfb5509db14c7da55eaf4f1614381301", json: true, type: .GET, bodyObject: [:]))
        usernameArray = parser.getArray(forKey: "author", messageDictionary: net.request(url: "https://constanze.live/api/v1/channels/148502836349636615/messages", token: token, Cookie: "__cfduid=d7ec9d856babfb5509db14c7da55eaf4f1614381301", json: true, type: .GET, bodyObject: [:]))
    }
    
    var body: some View {
        
//      chat view
        VStack(alignment: .leading) {
            Spacer()
            HStack {
//                chat view
                List(0..<messageArray.count, id: \.self) { index in
                    HStack {
                        Image("pfp").resizable()
                            .frame(maxWidth: 33, maxHeight: 33)
                            .clipShape(Circle())
                            .padding(.horizontal, 5)
                            .scaledToFill()
                        VStack(alignment: .leading) {
                            HStack {
                                Text((usernameArray[index] as? String ?? "").dropLast(5))
                                    .fontWeight(.bold)
                                if (usernameArray[index] as? String ?? "").suffix(5) != "#0000" {
                                    Text((usernameArray[index] as? String ?? "").suffix(5))
                                        .foregroundColor(Color.secondary)
                                }
                                if (usernameArray[index] as? String ?? "").suffix(5) == "#0000" {
                                    Text("Bot")
                                        .fontWeight(.semibold)
                                        .padding(2)
                                        .background(Color.pink)
                                        .cornerRadius(2)
                                }
                            }
                            Text(messageArray[index] as? String ?? "")
                        }
                        Spacer()
                        Button(action: {
                            print("cock")
                        }) {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .padding([.leading, .top], -25.0)
                .padding(.bottom, -9.0)
                
                
            }
            .padding(.leading, 25.0)
            
//            the controls part, easy
            
            HStack(alignment: .bottom) {
                TextField("What's wrong?", text: $chatTextFieldContents)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(EdgeInsets())

//                where messages are sent
                
                Button(action: {
                    messageArray = net.request(url: "https://constanze.live/api/v1/channels/148502836349636615/messages", token: token, Cookie: "__cfduid=d7ec9d856babfb5509db14c7da55eaf4f1614381301", json: false, type: .POST, bodyObject: ["content":"\(String(chatTextFieldContents))"])
                    refresh()
                }) {
                    Image(systemName: "paperplane.fill")
                }
                .coolButtonStyle()
                .shadow(radius: 2)
            }
            .padding()
        }
        .onAppear {
            refresh()
            print(token)
        }
    }
}
