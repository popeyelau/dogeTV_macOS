//
//  APIClient.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/4.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Alamofire
import PromiseKit

enum E: Error {
    case unknown
    case decodeFaild
    case serverError(msg: String)
}

extension E: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "服务器异常"
        case .decodeFaild:
            return "数据解析失败"
        case .serverError(let msg):
            return msg
        }
    }
}

class AlamofireManager: Alamofire.SessionManager {
    static let shared: AlamofireManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        return AlamofireManager(configuration: configuration)
    }()
}


struct R: Decodable {
    let code: Int
    let msg: String
}

struct APIClient {

    //FIXME:
    static func validate(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
        guard let data = data else {
            return .failure(E.unknown)
        }
        guard let resp = try? JSONDecoder().decode(R.self, from: data) else {
            return .failure(E.decodeFaild)
        }
        guard Array(200..<300).contains(resp.code) else {
            return .failure(E.serverError(msg: resp.msg))
        }
        return .success
    }

    static func fetch<T: Decodable>( _ target: Router) -> Promise<Response<T>> {
        return AlamofireManager.shared.request(target)
            .responseDecodable(Response<T>.self)
    }

    static func fetchHome() -> Promise<[Hot]>  {
        return AlamofireManager.shared.request(Router.home)
            .validate(validate)
            .responseDecodable(Response<[Hot]>.self)
            .map { $0.data }
    }


    
    static func fetchTopics() -> Promise<[Topic]> {
        return AlamofireManager.shared.request(Router.topics)
            .validate(validate)
            .responseDecodable(Response<[Topic]>.self)
            .map { $0.data }
    }
    
    static func search(keywords: String, page: Int = 1) -> Promise<[Video]> {
        return AlamofireManager.shared.request(Router.search(keywords: keywords, page: page))
            .validate(validate)
            .responseDecodable(Response<[Video]>.self)
            .map { $0.data }
    }

    static func fetchTopic(id: String) -> Promise<TopicDetail> {
        return AlamofireManager.shared.request(Router.topic(id: id))
            .validate(validate)
            .responseDecodable(Response<TopicDetail>.self)
            .map { $0.data }
    }

    static func fetchEpisodes(id: String, source: Int = 0) -> Promise<[Episode]> {
        return AlamofireManager.shared.request(Router.episodes(id: id, source: source))
            .validate(validate)
            .responseDecodable(Response<[Episode]>.self)
            .map { $0.data }
    }

    static func fetchVideo(id: String) -> Promise<VideoDetail> {
        return AlamofireManager.shared.request(Router.video(id: id))
            .validate(validate)
            .responseDecodable(Response<VideoDetail>.self)
            .map { $0.data }
    }

    
    static func fetchCategoryList(category: Category, page: Int = 1, isDouban: Bool = false, query: String = "") -> Promise<VideoCategory> {
        return AlamofireManager.shared.request(Router.category(category: category, page: page, isDouban: isDouban, query: query))
            .validate(validate)
            .responseDecodable(Response<VideoCategory>.self)
            .map { $0.data }
    }

    static func fetchRankList(category: Category) -> Promise<[Ranking]> {
        return AlamofireManager.shared.request(Router.rank(category: category))
            .validate(validate)
            .responseDecodable(Response<[Ranking]>.self)
            .map { $0.data }
    }

    static func fetchResourceCount(id: String) -> Promise<Int> {
        return AlamofireManager.shared.request(Router.resource(id: id))
            .validate(validate)
            .responseDecodable(Response<Int>.self)
            .map { $0.data }
    }

    static func resolveUrl(url: String) -> Promise<String> {
        return AlamofireManager.shared.request(Router.resolve(url: url))
            .validate(validate)
            .responseDecodable(Response<String>.self)
            .map { $0.data }
    }
    
    static func fetchTV(_ tv: TV) -> Promise<[ChannelGroup]> {
        return AlamofireManager.shared.request(Router.tv(tv: tv))
            .validate(validate)
            .responseDecodable(Response<[ChannelGroup]>.self)
            .map { $0.data }
    }
    
    static func cloudParse(url: String) -> Promise<CloudParse> {
        return AlamofireManager.shared.request(Router.parse(url: url))
            .validate(validate)
            .responseDecodable(Response<CloudParse>.self)
            .map { $0.data }
    }

    static func parse(url: String) -> Promise<CloudParse> {
        return AlamofireManager.shared.request(Router.parse(url: url))
            .validate(validate)
            .responseDecodable(Response<CloudParse>.self)
            .map { $0.data }
    }
}
