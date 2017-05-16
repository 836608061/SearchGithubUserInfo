//
//  ApiManagerProvider.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/15.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit

    // 用于回调发起请求的对象，通知其网络请求的结果
    protocol ApiManagerCallBackProtocol: class {
        func managerCallAPIDidSuccess(manager: ApiBaseManager)
        func managerCallAPIDidFailed(manager: ApiBaseManager, errorCode: String?)
    }
    //为网络请求提供 请求相对路径 和 参数
    protocol ApiManagerProvider: class {
        func urlPathComponentForManager(manager: ApiBaseManager) -> String
        func parametersForManager(manager: ApiBaseManager) -> Dictionary<String, AnyObject>?
    }
