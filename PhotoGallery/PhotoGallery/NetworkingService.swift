//
//  NetworkingService.swift
//  PhotoGallery
//
//  Created by Admin on 20/06/2020.
//  Copyright © 2020 Paolo Esposito. All rights reserved.
//

import Foundation


class NetworkingService {

    static let shared = NetworkingService()
    private init() {}

    let session = URLSession.shared
    var searchKey = ""
    //MARK: GET API for Reddit

    func getReddits(success successBlock: @escaping (Model) -> Void) {
        if (searchKey == ""){
            return
        }
        guard let url = URL(string: "https://www.reddit.com/r/\(searchKey)/top.json") else { return }
        
        let request = URLRequest(url: url)

        session.dataTask(with: request) { [weak self] data, _, error in
            guard self != nil else { return }

            if let error = error { print(error); return }
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(Model.self, from: data!)
                successBlock(model)
            } catch {
                print(error)
                return
            }
            }.resume()
    }
}


//MARK: Data Models

struct Model : Decodable {
    let data: Children
}

struct Children: Decodable {
    let dist: Int
    let children: [SubRedditData]
}

struct SubRedditData: Decodable {
    let data: SecondaryData
    let kind: String
}

struct SecondaryData : Decodable {
    let title: String
    let url: URL

}

