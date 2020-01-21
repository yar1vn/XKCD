//
//  API.swift
//  XKCD
//
//  Created by Yariv on 1/20/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case invalidURL
    case badResponse(Error)
    case unknown(Error)
}

protocol XKCDServiceProtool {
    typealias Completion = (Result<Comic, ServiceError>) -> Void
    func getLatestComic(completion: @escaping Completion)
    func getComic(num: Int, completion: @escaping Completion)
}

struct XKCDService: XKCDServiceProtool {
    private let baseURL: URL
    private let suffix: String
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.baseURL = URL(string: "https://xkcd.com")!
        self.suffix = "info.0.json"
        self.urlSession = urlSession
    }

    init(baseURL: String, suffix: String = "info.0.json", urlSession: URLSession = .shared) throws {
        guard let url = URL(string: "https://\(baseURL)/")
            else { throw ServiceError.invalidURL }

        self.baseURL = url
        self.suffix = suffix
        self.urlSession = urlSession
    }

    private func get(with url: URL?, completion: @escaping Completion) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }
        urlSession.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                // force unwrap: error is guaranteed to be non-nil when data is empty (see docs)
                completion(.failure(.unknown(error!)))
                return
            }
            do {
                let comic = try Comic(data: data)
                completion(.success(comic))
            } catch {
                completion(.failure(.badResponse(error)))
            }
        }.resume()
    }

    func getLatestComic(completion: @escaping Completion) {
        get(with: URL(string: "/\(suffix)", relativeTo: baseURL), completion: completion)
    }

    func getComic(num: Int, completion: @escaping Completion) {
        get(with: URL(string: "/\(num)/\(suffix)", relativeTo: baseURL), completion: completion)
    }
}
