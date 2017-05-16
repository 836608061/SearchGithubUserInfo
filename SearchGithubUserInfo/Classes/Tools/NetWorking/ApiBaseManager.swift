//
//  ApiBaseManager.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/15.
//  Copyright © 2017年 menhao. All rights reserved.
//
import Foundation

enum ManagerRequestMethod : String {
    
    case RequestMethodRestGET//, HEAD, , PUT, PATCH, DELETE, TRACE, CONNECT
    case RequestMethodRestPOST
}

//reform data for containers(Array/Dictionary) to contain strings for view to display
protocol DataAdaptorProtocol {
    func reformResponseData(responseData: AnyObject, withManager: ApiBaseManager) -> AnyObject?
}


//every children class need to conform to this protocol
protocol ApiManagerProtocol: NSObjectProtocol {
    
    var requestMethod: ManagerRequestMethod { get }
    var responseDataType: APIResponseDataType { get }
}

class ApiBaseManager: NSObject {
    let sema =  DispatchSemaphore(value: 1)
    //MARK: - functions
    func loadData() -> NSNumber? {
        
        guard let urlProvider = urlProviderDelegate else {
            return nil
        }
        
        cleanResponseData()
        
        let urlComponent = urlProvider.urlPathComponentForManager(manager: self)
        if urlComponent.isEmpty {
            return nil
        }
        
        let parameters = urlProvider.parametersForManager(manager: self)
        
        var requestMethod = ManagerRequestMethod.RequestMethodRestGET
        var responseDataType = APIResponseDataType.Json
        
        if let _ = requestCustomizeDelegate {
            
            requestMethod = requestCustomizeDelegate!.requestMethod
            responseDataType = requestCustomizeDelegate!.responseDataType
        }
        
        var requestId: NSNumber
        MBProgressHUD.showMessage("请稍后...")
        switch requestMethod {
            
        case .RequestMethodRestGET:
            
            requestId = ApiProxy.sharedInstance.makeRestGetRequestForUrl(url: urlComponent, parameters: parameters, responseDataType: responseDataType, successedCallBack: requestSuccessed, failedCallBack: requestFailed)
            
        case .RequestMethodRestPOST:
            
            requestId = ApiProxy.sharedInstance.makeRestPostRequestForUrl(url: urlComponent, parameters: parameters, responseDataType: responseDataType, successedCallBack: requestSuccessed, failedCallBack: requestFailed)
        }
      
        allRequestIds.append(requestId)
        return requestId
    }
    
    //clean data for new request
    func cleanResponseData() {
        ResponseRawData = nil
        ResponseError = nil
    }
    
    func cancellRequest(requestId: NSNumber) {
        
        guard let index = getRequestIndex(requestId: requestId) else {
            return
        }
        
        ApiProxy.sharedInstance.cancellRequestForId(requestId: requestId)
        allRequestIds.remove(at: index)
    }
    
    func cancellAllRequests() {
        
        let count = allRequestIds.count
        for index in 0..<count {
            ApiProxy.sharedInstance.cancellRequestForId(requestId: allRequestIds[index])
            allRequestIds.remove(at: index)
        }
    }
    
    func removeRequestId(requestId: NSNumber) {
        
        guard let index = getRequestIndex(requestId: requestId) else {
            return
        }
        
        allRequestIds.remove(at: index)
    }
    
    func getRequestIndex(requestId: NSNumber) -> Int? {
        for (index, value) in allRequestIds.enumerated() {
            if value == requestId {
                return index
            }
        }
        
        return nil
    }
    
    //called after request successed
    func getReformedDataByAdaptor(adaptor: DataAdaptorProtocol) -> AnyObject? {
        if let _ = self.ResponseRawData {
            return adaptor.reformResponseData(responseData: self.ResponseRawData!, withManager: self)
        }
        
        return self.ResponseRawData
    }
    
    private
    //request callbacks
    func requestSuccessed(responseObj: AnyObject, requestId: NSNumber) {
     MBProgressHUD.hide()
        ResponseRawData = responseObj
        
        if let responseDic = responseObj as? Dictionary<String, AnyObject>{
            let result = responseDic["incomplete_results"] as? Bool
            guard result   == false else {
                if let _ = apiCallBackDelegate {
                    apiCallBackDelegate?.managerCallAPIDidFailed(manager: self, errorCode: nil)
                }
                return
            }
        }
        
        if let _ = apiCallBackDelegate {
            apiCallBackDelegate?.managerCallAPIDidSuccess(manager: self)
        }
        removeRequestId(requestId: requestId)
       
    }
    

    
    func requestFailed(responseError: NSError, requestId: NSNumber) {
       MBProgressHUD.hide()
        ResponseError = responseError
        
        if let _ = apiCallBackDelegate {
            apiCallBackDelegate?.managerCallAPIDidFailed(manager: self, errorCode: nil)
        }
        
        removeRequestId(requestId: requestId)
   
    }
    
    
    //MARK: - life cycle
    init(urlProvider: ApiManagerProvider?) {
        super.init()
        
        urlProviderDelegate = urlProvider
        
        if self is ApiManagerProtocol {
            requestCustomizeDelegate = self as? ApiManagerProtocol
        }
    }
    
    deinit {
                cancellAllRequests()
    }
    
    
    //MARK: instance variables
    var ResponseRawData: AnyObject?
    var ResponseError: NSError?
    var allRequestIds = Array<NSNumber>()
    
    //delegates
    weak var apiCallBackDelegate: ApiManagerCallBackProtocol?
    weak var urlProviderDelegate: ApiManagerProvider?
    weak var requestCustomizeDelegate: ApiManagerProtocol?
}
