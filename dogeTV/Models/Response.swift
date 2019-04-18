//
//  Response.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/3/15.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation

struct Response<T: Decodable>: Decodable{
    let code: Int
    let msg: String
    let data: T
}
