//
//  Comic.swift
//  XKCD
//
//  Created by Yariv on 1/20/20.
//  Copyright © 2020 Yariv. All rights reserved.
//

import Foundation

// MARK: - Comic
struct Comic: Codable, Hashable {
    let month: String
    let num: Int
    let link, year, news, safeTitle: String
    let transcript, alt: String
    let img: String
    let title, day: String

    enum CodingKeys: String, CodingKey {
        case month, num, link, year, news
        case safeTitle = "safe_title"
        case transcript, alt, img, title, day
    }
}

extension Comic {
    init(data: Data) throws {
        self = try JSONDecoder().decode(type(of: self), from: data)
    }
}
