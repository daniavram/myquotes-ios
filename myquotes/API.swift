//
//  API.swift
//  my-quotes
//
//  Created by Daniel Avram on 09/03/2017.
//  Copyright © 2017 Daniel Avram. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

enum Endpoint: String {
    
    private static let base = "https://myquotes.io/api/"
    
    case authors = "authors/"
    case categories = "categories/"
    case tags = "tags/"
    case quotes = "quotes/"
    case tokenNew = "token/new/"
    case tokenRefresh = "token/refresh/"
    case token = "token/verify/"
    
    func url(id: Int? = nil, search: String? = nil, tags: [String]? = nil) -> String {
        
        var endpointString: String = Endpoint.base + self.rawValue
        
        guard let id = id else {
            
            switch self {
            case .quotes:
                endpointString += "?page=1&page_size=1000"
                
                if let search = search, search != "" {
                    endpointString += "&search=\(search)"
                }
                if let tags = tags {
                    for tag in tags {
                        endpointString += "&tags=\(tag)"
                    }
                }
            case .authors:
                if let search = search, search != "" {
                    endpointString += "?name=\(search)"
                }
            default:
                break
            }
            
            return endpointString
        }
        
        return endpointString + "\(id)/"
    }
    
}

struct API {
    
    fileprivate static var token = ""
    fileprivate static var headers: HTTPHeaders {
        
        let headers = [
            "Authorization" : "JWT " + API.token
        ]
        
        return headers
    }
    
    fileprivate static func url<T: Mappable>(for object: T, containing: String?) -> String {
        
        var endpoint: Endpoint!
        
        if object is Author {
            endpoint = Endpoint.authors
        } else if object is Category {
            endpoint = Endpoint.categories
        } else if object is Tag {
            endpoint = Endpoint.tags
        } else if object is Quote {
            endpoint = Endpoint.quotes
        }
        
        return endpoint.url(search: containing)
    }
    
    fileprivate static func getObject<T:Mappable>(url: String, completion: @escaping (T?, Error?) -> Void ) {
        
        let resp = Alamofire.request(url, headers: API.headers).responseObject { (response: DataResponse<T>) in
            
            guard response.result.isSuccess else {
                completion(nil, response.result.error)
                return
            }
            
            completion(response.result.value, nil)
        }
        debugPrint(resp)
    }
    
    fileprivate static func getArray<T:Mappable>(url: String, completion: @escaping ([T]?, Error?) -> Void ) {
        
        Alamofire.request(url, headers: API.headers).responseArray { (response: DataResponse<[T]>) in
            
            guard response.result.isSuccess else {
                completion(nil, response.result.error)
                return
            }
            
            completion(response.result.value, nil)
            
        }
    }
    
    fileprivate static func postObject<T: Mappable>(url: String, object: T, completion: @escaping (T?, Error?) -> Void ) {
        
        Alamofire.request(url, method: .post, parameters: object.toJSON(), encoding: JSONEncoding.default, headers: API.headers).responseObject { (response: DataResponse<T>) in
            
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    completion(nil, response.result.error)
                    return
            }
            
            let responseObject = response.result.value
            
            completion(responseObject, nil)
        }
        
    }
    
}

extension API {
    
    static func updateHeaders(token: String) {
        API.token = token
    }
    
    static func getToken(authenticationRequest: Authentication, completion: @escaping (Authentication?) -> Void) {
        
        Alamofire.request(Endpoint.tokenNew.url(), method: .post, parameters: authenticationRequest.toJSON(), encoding: JSONEncoding.default).responseObject { (response: DataResponse<Authentication>) in
            
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    completion(nil)
                    return
            }
            
            let authentication = response.result.value
            API.token = authentication?.token ?? ""
            
            completion(authentication)
        }
    }
    
    static func refreshToken(completion: @escaping (Void) -> Void) {
        
        let authenticationRequest = Authentication(token: API.token)
        
        Alamofire.request(Endpoint.tokenRefresh.url(), method: .post, parameters: authenticationRequest.toJSON(), encoding: JSONEncoding.default).responseObject { (response: DataResponse<Authentication>) in
            
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    return
            }
            
            let authentication = response.result.value
            
            API.token = authentication?.token ?? ""
            
            completion()
        }
    }
    
    static func checkToken(completion: @escaping (Authentication?) -> Void) {
        
        let authenticationRequest = Authentication(token: API.token)
        
        Alamofire.request(Endpoint.token.url(), method: .post, parameters: authenticationRequest.toJSON(), encoding: JSONEncoding.default).responseObject { (response: DataResponse<Authentication>) in
            
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    completion(nil)
                    return
            }
            
            let authentication = response.result.value
            
            API.token = authentication?.token ?? ""
            
            completion(authentication)
        }
    }
    
    static func get<T: Mappable>(_ object: T, containing: String? = nil, completion: @escaping ([T]) -> Void) {
        
        let url = API.url(for: object, containing: containing)
        
        API.getArray(url: url, completion: { (result: [T]?, error: Error?) -> Void in
            
            let responseArray = result ?? [T]()
            
            completion(responseArray)
        })
    }
    
    static func getQuotes(containing: String? = nil, tags: [String]? = nil, completion: @escaping (QuotesResponse) -> Void) {
        
        let urlString = Endpoint.quotes.url(search: containing, tags: tags)
        
        API.getObject(url: urlString, completion: { (response: QuotesResponse?, error: Error?) -> Void in
            
            let quotesResponse = response ?? QuotesResponse()
            
            completion(quotesResponse)
            
        })
    }
    
    static func post<T: Mappable>(object: T, completion: @escaping (T?) -> Void) {
        
        let url = API.url(for: object, containing: nil)
        
        API.postObject(url: url, object: object, completion: { response, error in
            
            guard error == nil else {
                completion(nil)
                return
            }
            
            completion(response)
        })
        
    }
    
    static func post(quote: [String: Any], completion: @escaping (Bool) -> Void) {
        
        Alamofire.request(Endpoint.quotes.url(), method: .post, parameters: quote, encoding: JSONEncoding.default, headers: API.headers).responseJSON { response in
            
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    completion(false)
                    return
            }
            
            completion(true)
        }
        
        
    }
    
    static func delete(_ what: Endpoint, id: Int, completion: @escaping (Bool) -> Void) {
        
        Alamofire.request(what.url(id: id), method: .delete, headers: API.headers).response { response in
            guard let statusCode = response.response?.statusCode,
                200..<300 ~= statusCode else {
                    completion(false)
                    return
            }
            
            completion(true)
        }
        
    }
    
}
