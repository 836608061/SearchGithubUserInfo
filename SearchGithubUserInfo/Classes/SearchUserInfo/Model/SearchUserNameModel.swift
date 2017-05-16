//
//  SearchUserNameModel.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/15.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit

typealias SearchUserNameModelCallBack = ([SearchUserNameModel])->()
class SearchUserNameModel: NSObject,ApiManagerCallBackProtocol, ApiManagerProvider{
    //MARK: - property
    var dataSourceCallBack : SearchUserNameModelCallBack?
    var dataSource = [SearchUserNameModel]()
    var avatar_url = ""
    var login = ""
    var inputStr = ""
    var searchUserNameApiManager : ApiSearchUserNameManager? = nil
    //MARK: - loadData
    func refreashDataAndShow(){
        searchUserNameApiManager = ApiSearchUserNameManager(urlProvider: self)
        let _ = searchUserNameApiManager?.loadData()
        searchUserNameApiManager?.apiCallBackDelegate = self
    }
    //MARK: - callBack
    func managerCallAPIDidSuccess(manager: ApiBaseManager) {
        if let dataRes = manager.ResponseRawData{
        if let item =  dataRes["items"]{
            let arrM = SearchUserNameModel.mj_objectArray(withKeyValuesArray: item!) as Array
            self.dataSource = arrM as! [SearchUserNameModel]
            self.dataSourceCallBack?(self.dataSource)
        }
        }
    }
    
    func managerCallAPIDidFailed(manager: ApiBaseManager, errorCode: String?) {
        
    }
     //MARK: - urlProvider
    func urlPathComponentForManager(manager: ApiBaseManager) -> String {
        return "https://api.github.com/search/users?q=" + self.inputStr
    }
    
    func parametersForManager(manager: ApiBaseManager) -> Dictionary<String, AnyObject>? {
        return nil
    }
}
