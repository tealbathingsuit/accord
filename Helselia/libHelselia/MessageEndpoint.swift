//
//  MessageEndpoint.swift
//  Helselia
//
//  Created by evelyn on 2021-03-07.
//

import Foundation
import SwiftUI


public class parseMessages {
    func getItem(forKey: String, secondary: Bool, secondaryItem: String, messageDictionary: [[String:Any]], position: Int) -> Any {
        var returnItem: Any = ""
        for item in messageDictionary[position].keys {
            if item == forKey {
                returnItem = messageDictionary[position][item] ?? ""
                break
            } else {
                returnItem = "Key Not Found In Item."
            }
        }
        if secondary == true {
            if type(of: returnItem) == Dictionary<String, Any>.self {
                for i in (returnItem as! Dictionary<String, Any>).keys {
                    if i == secondaryItem {
                        returnItem = secondaryItem
                    }
                }
            }
        }
        return returnItem
    }
    func getArray(forKey: String, messageDictionary: [[String:Any]]) -> [Any] {
        var returnItem: [Any] = []
        for message in messageDictionary {
            for item in message.keys {
                if item == forKey {
                    if forKey == "author" {
                        returnItem.append("\((message[item] as! Dictionary<String, Any>)["username"] ?? "error")#\((message[item] as! Dictionary<String, Any>)["discriminator"] ?? "0000")" )
                    } else {
                        returnItem.append(message[item] ?? "")
                    }
                } else if forKey == "avatar" && item == "author" {
                    returnItem.append("https://cdn.constanze.live/avatars/\((message[item] as! Dictionary<String, Any>)["id"] ?? "error")/\((message[item] as! Dictionary<String, Any>)["avatar"] ?? "error").png")
                }
            }
        }
        return returnItem
    }
}

#warning("rewrite this shit you lazy bitch (evelyn)")

struct ImageWithURL: View {
    
    @ObservedObject var imageLoader: ImageLoaderAndCache

    init(_ url: String) {
        imageLoader = ImageLoaderAndCache(imageURL: url)
    }

    var body: some View {
        Image(nsImage: (NSImage(data: self.imageLoader.imageData) ?? NSImage(named: "sad")) ?? NSImage())
              .resizable()
              .clipped()
    }
}

class ImageLoaderAndCache: ObservableObject {
    
    @Published var imageData = Data()
    
    init(imageURL: String) {
        let cache = URLCache.shared
        let request = URLRequest(url: (URL(string: imageURL) ?? URL(string: "https://nitroless.quiprr.dev/frrtx.png"))!, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60.0)
        if let data = cache.cachedResponse(for: request)?.data {
            self.imageData = data
        } else {
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response {
                let cachedData = CachedURLResponse(response: response, data: data)
                                    cache.storeCachedResponse(cachedData, for: request)
                    DispatchQueue.main.async {
                        self.imageData = data
                    }
                }
            }).resume()
        }
    }
}
