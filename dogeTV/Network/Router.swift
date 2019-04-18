//
//  Router.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/4.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Alamofire


/*
 Film        MediaType = 1 //电影1
 Drama       MediaType = 2 //电视剧2
 Variety     MediaType = 3 //综艺3
 Cartoon     MediaType = 4 //动漫4
 Documentary MediaType = 5 //记录片5
 */
enum Category: Int, CaseIterable {
    case film
    case drama
    case variety
    case cartoon
    case documentary

    var categoryKey: String {
        switch self {
        case .film: return "film"
        case .drama: return "drama"
        case .variety: return "variety"
        case .cartoon: return "cartoon"
        case .documentary: return "documentary"
        }
    }

    var title: String {
        switch self {
        case .film: return "电影"
        case .drama: return "电视剧"
        case .variety: return "综艺"
        case .cartoon: return "动漫"
        case .documentary: return "记录片"
        }
    }
    
    static func fromCategoryKey(_ key: String) -> Category{
        return Category.allCases.first { $0.categoryKey == key } ?? .film
    }
}

protocol APIConfiguration: URLRequestConvertible {
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: Parameters? { get }
}


enum Router: APIConfiguration {
    case home
    case topics
    case category(category: Category, page: Int, isDouban: Bool, query: String)
    case rank(category: Category)
    case topic(id: String)
    case video(id: String)
    case episodes(id: String, source: Int)
    case search(keywords: String, page: Int)
    case resolve(url: String)
    case resource(id: String)
    case tv(tv: TV)
    case parse(url: String)

    var method: HTTPMethod {
        switch self {
        case .resolve:
            return .post
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .tv:
            return "/tv"
        case .home:
            return "/videos"
        case .topics:
            return "/topics"
        case .category(let category,_,let isDouban,_):
            return isDouban ? "/douban/\(category.categoryKey)" : "/videos/\(category.categoryKey)"
        case .rank(let category):
            return "/ranking/\(category.categoryKey)"
        case .topic(let id):
            return "/topic/\(id)"
        case .video(let id):
            return "/video/\(id)"
        case .episodes(let id, _):
            return "/video/\(id)/episodes"
        case .search:
            return "/search"
        case .resolve:
            return "/video/resolve"
        case .resource(let id):
            return "/resource/\(id)"
        case .parse:
            return "/parse"
        }
    }

    var parameters: Parameters? {
        switch self {
        case .tv(let tv):
            return ["f": tv.key]
        case .category(_, let page,_,let query):
            return ["p": page, "query": query]
        case .search(let keywords, let page):
            return ["wd": keywords, "p": page]
        case .resolve(let url):
            return ["url": url]
        case .episodes(_, let source):
            return ["source": source]
        case .parse(let url):
            return ["url": url.base64String]
        default:
            return nil
        }

    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try ENV.host.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        
        request.httpMethod = method.rawValue
        return try encoding.encode(request, with: parameters)
    }
}



