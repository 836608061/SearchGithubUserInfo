
//
//  ApiSearchFavirLagManager.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/16.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit

class ApiSearchFavirLagManager: ApiBaseManager,ApiManagerProtocol {
        var requestMethod: ManagerRequestMethod {
            get {
                return .RequestMethodRestGET
            }
        }
        
        var responseDataType: APIResponseDataType {
            get {
                return .Json
            }
        
}
}
