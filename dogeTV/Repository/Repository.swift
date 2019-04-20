//
//  Repository.swift
//  dogeTV
//
//  Created by Popeye Lau on 2019/4/19.
//  Copyright © 2019 Popeye Lau. All rights reserved.
//

import Foundation
import WCDBSwift

let dbVersionKey = "db_version"

class History: TableCodable {
    var id: Int? = nil
    var primaryKey: String = "'"
    var videoId: String = ""
    var name: String = ""
    var episode: Int = 0
    var episodeName: String = ""
    var source: Int = 0
    var currentTime: Double = 0
    var duration: Double = 0
    var cover: String = ""
    var createDate: Date = Date()

    enum CodingKeys: String, CodingTableKey {
        typealias Root = History
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case id
        case primaryKey
        case videoId
        case name
        case episode
        case episodeName
        case source
        case currentTime
        case duration
        case cover
        case createDate

        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isAutoIncrement: true),
                primaryKey: ColumnConstraintBinding(isPrimary: true),
            ]
        }
    }
}

class Repository {

    static let database = Database(withPath: ENV.dbPath)

    static var shouldUpdate: Bool {
        guard let version = UserDefaults.standard.string(forKey: dbVersionKey) else {
            return true
        }
        return version != ENV.dbVersion
    }

    class func createTables() {
        guard shouldUpdate else { return }

        do {
            try database.run(transaction: {
                try database.create(table: String(describing: History.self), of: History.self)
            })
            UserDefaults.standard.set(ENV.dbVersion, forKey: dbVersionKey)
        } catch {
            print("初始化数据库失败")
        }
    }

    class func insertOrReplace<T: TableCodable>(table: T){
        do {
            let tableName = String(describing: T.self)
            try database.insertOrReplace(objects: [table], intoTable: tableName)
        } catch {
            print("新增/更新失败")
        }
    }

    class func truncate<T: TableCodable>(table: T.Type) {
        do {
            let tableName = String(describing: table)
            try database.delete(fromTable: tableName)
        } catch  {
            print("清空表失败")
        }
    }

    class func getObjects<T: TableCodable>(table: T.Type,condition : Condition? = nil, orderBy: [OrderBy]? = nil) -> [T]? {
        do {
            let tableName = String(describing: table)
            let objects : [T] = try database.getObjects(on: table.Properties.all, fromTable: tableName, where: condition, orderBy: orderBy, offset: nil)
            return objects
        } catch {
            return nil
        }
    }
}
