//
//  VideoService.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/5/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation
import PromiseKit


class VideoService {
    static let shared = VideoService()
    
    func getVideoDetails(video: Video) -> Promise<(VideoDetail, [Episode])> {
        
        let id = video.id
        let source = video.sourceType

        switch source{
        case .other:
            return attempt(maximumRetryCount: 3) {
                when(fulfilled: APIClient.fetchVideo(id: id),
                     APIClient.fetchEpisodes(id: id))
            }
        case .pumpkin:
            return attempt(maximumRetryCount: 3) {
                APIClient.fetchPumpkin(id: id)
                }.then(fetchPumpkinStreamURL)
        case .blueray:
            return attempt(maximumRetryCount: 3) {
                APIClient.fetchBlueVideo(id: id).compactMap { detail in
                    guard let episodes = detail.seasons?.first?.episodes else {
                        return nil
                    }
                    let video = VideoDetail(info: detail.info, recommends: detail.recommends, seasons: nil)
                    return (video, episodes)
                }
            }
        }
    }
    

    func fetchPumpkinStreamURL(video: VideoDetail) -> Promise<(VideoDetail, [Episode])> {
        if let episodes = video.seasons?.first?.episodes {
            return Promise<(VideoDetail, [Episode])> { resolver in
               resolver.fulfill((video, episodes))
            }
        }
        return APIClient.fetchPumpkinEpisodes(id: video.info.id).map { episodes in
            (video, episodes)
            
        }
    }
    
}
