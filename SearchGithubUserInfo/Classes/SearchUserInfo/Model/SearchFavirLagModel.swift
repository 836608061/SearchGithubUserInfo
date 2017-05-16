//
//  SearchFavirLagModel.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/16.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit
typealias SearchLangModelCallBack = ([SearchFavirLagModel])->()
class SearchFavirLagModel: NSObject ,ApiManagerCallBackProtocol, ApiManagerProvider{
//MARK: - property
 var inputStr = ""
 var language = ""
 var dataSource = [SearchFavirLagModel]()
 var searchFavirLagManager : ApiSearchFavirLagManager? = nil
 var dataSourceCallBack : SearchLangModelCallBack?
//MARK: - loadData
    func refreashDataAndShow(){
        searchFavirLagManager = ApiSearchFavirLagManager(urlProvider: self)
        let _ = searchFavirLagManager?.loadData()
        searchFavirLagManager?.apiCallBackDelegate = self
    }
  //MARK: - callBack
    func managerCallAPIDidSuccess(manager: ApiBaseManager) {
        if let dataRes = manager.ResponseRawData{
                let arrM = SearchFavirLagModel.mj_objectArray(withKeyValuesArray: dataRes) as Array
                self.dataSource = arrM as! [SearchFavirLagModel]
                self.dataSourceCallBack?(self.dataSource)
        }
    }
    
    func managerCallAPIDidFailed(manager: ApiBaseManager, errorCode: String?) {
        
    }
    //MARK: - urlProvider
    func urlPathComponentForManager(manager: ApiBaseManager) -> String {
        return "https://api.github.com/users/" + self.inputStr + "/repos"
    }
    
    func parametersForManager(manager: ApiBaseManager) -> Dictionary<String, AnyObject>? {
        return nil
    }

    
}
