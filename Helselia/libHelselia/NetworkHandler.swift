//
//  NetworkHandler.swift
//  Helselia
//
//  Created by evelyn on 2021-02-27.
//


import Foundation

let debug = true

public class NetworkHandling {
    func request(url: String, token: String, Cookie: String, json: Bool, type: requests.requestTypes, bodyObject: [String:Any]) -> [[String:Any]] {
        var completion: Bool = false
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: (URL(string: url) ?? URL(string: "#"))!)
        var retData: Data = Data()
        switch type {
        case .GET:
            request.httpMethod = "GET"
        case .POST:
            request.httpMethod = "POST"
        case .PATCH:
            request.httpMethod = "PATCH"
        case .DELETE:
            request.httpMethod = "DELETE"
        case .PUT:
            request.httpMethod = "PUT"
        }
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(Cookie, forHTTPHeaderField: "Cookie")
        if type == .POST {
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
            print(bodyObject)
        }
        var returnArray: [[String:Any]] = []
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                retData = Data(data!)
                if json == true {
                    do {
                        returnArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:Any]] ?? [[String:Any]]()
                    } catch {
                        print("error at serializing: \(error.localizedDescription)")
                    }
                } else {
                    returnArray = [["Code":statusCode]]
                }
                if debug {
                    print("URL Session Task Succeeded: HTTP \(statusCode)")
                }
            }
            else {
                print("URL Session Task Failed: %@", error!.localizedDescription);
            }
        })
        if type == .GET {
            while completion == false {
                task.resume()
                session.finishTasksAndInvalidate()
                sleep(1)
                if retData != Data() {
                    completion = true
                    break
                }
            }
        } else {
            task.resume()
            session.finishTasksAndInvalidate()
            sleep(1)
        }
        return returnArray
    }
    func checkConnection() -> Bool {
        var ret: Bool = false
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: (URL(string: "https://constanze.live/api/v1/auth/login") ?? URL(string: "#"))!)
        request.httpMethod = "POST"
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                let statusCode = (response as! HTTPURLResponse).statusCode
                // Success
                ret = true
                print("URL Session Task Succeeded: HTTP \(statusCode)")
            }
            else {
                // Failure
                ret = false
            }
        })
        do {
            task.resume()
            session.finishTasksAndInvalidate()
            return ret
        } catch {
            print("not responding")
            ret = false
            return ret
        }
    }
}
