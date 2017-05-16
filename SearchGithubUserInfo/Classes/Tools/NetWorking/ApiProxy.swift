//
//  ApiProxy.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/15.
//  Copyright © 2017年 menhao. All rights reserved.
//
import Foundation
import Alamofire

public enum APIResponseDataType: String {
    case Json
    case UTF8String
    case RawData
}



typealias SuccessCallBack = (_ responseObj: AnyObject, _ requestId: NSNumber)->(Void)
typealias FailedCallBack = (_ responseError: NSError, _ requestId: NSNumber)->(Void)

class ApiProxy {
    
    //MARK: api call function
    func makeRestGetRequestForUrl(url: String, parameters: Dictionary<String, AnyObject>?, responseDataType: APIResponseDataType, successedCallBack: @escaping SuccessCallBack, failedCallBack: @escaping FailedCallBack) -> NSNumber {
        
        return callApiWithMethod(method: "GET", URLString: url, parameters: parameters, encoding: JSONEncoding() as ParameterEncoding, responseDataType: responseDataType, successCallBack: successedCallBack, failedCallBack: failedCallBack)
    }
    
    func makeRestPostRequestForUrl(url: String, parameters: Dictionary<String, AnyObject>?, responseDataType: APIResponseDataType, successedCallBack: @escaping SuccessCallBack, failedCallBack: @escaping FailedCallBack) -> NSNumber {
        
        return callApiWithMethod(method: "POST", URLString: url, parameters: parameters, encoding:URLEncoding() as ParameterEncoding, responseDataType: responseDataType, successCallBack: successedCallBack, failedCallBack: failedCallBack)
    }
    
    //MARK: - request collection manuplation
    func cancellRequestForId(requestId: NSNumber) {
        guard let request = self.storedRequests[requestId] else{
            return
        }
        //        if let req = request {
        request.cancel()
        self.storedRequests.removeValue(forKey: requestId)
        //        }
    }
    
    func cancellRequestsWithIdList(idList: Array<NSNumber>) {
        for num in idList {
            self.cancellRequestForId(requestId: num)
        }
    }
    
    func cancellAllRequest() {
        for req in self.storedRequests {
            req.1.cancel()
        }
        
        self.storedRequests.removeAll()
    }
    
    
    //proxy to alamofire framework
    func callApiWithMethod(method: String, URLString: String, parameters: [String : AnyObject]?, encoding: ParameterEncoding, responseDataType: APIResponseDataType, successCallBack: @escaping SuccessCallBack, failedCallBack: @escaping FailedCallBack) -> NSNumber {
        let requestId = generateRequestId()
        let requestMethod = HTTPMethod.init(rawValue: method)
    
        var apiRequest: DataRequest
        apiRequest = Alamofire.request(URLString, method: requestMethod!, parameters: parameters, encoding: encoding, headers: nil)
        
        switch responseDataType {
        case .Json:
            apiRequest.responseJSON(queue: nil, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: { (urlResponse) in
                  self.requestFinished(urlResponse: urlResponse, requestId: requestId, successCallBack: successCallBack, failedCallBack: failedCallBack)
            })
           
        case .UTF8String:
     
            apiRequest.responseString(queue: nil, encoding: String.Encoding.utf8, completionHandler: { (urlResponse) in
                self.requestFinished(urlResponse: urlResponse, requestId: requestId, successCallBack: successCallBack, failedCallBack: failedCallBack)
            })
        case .RawData:
            apiRequest.responseData(queue: nil, completionHandler: { (urlResponse) in
                self.requestFinished(urlResponse: urlResponse, requestId: requestId, successCallBack: successCallBack, failedCallBack: failedCallBack)
            })
        }
        
        return requestId
    }
    
    
    
    func requestFinished<T>(urlResponse: DataResponse<T>, requestId: NSNumber, successCallBack: SuccessCallBack, failedCallBack: FailedCallBack) {
        guard urlResponse.result.error == nil else {
            //deal with failure for request
            
            failedCallBack(urlResponse.result.error as! NSError, requestId)
            return
        }
        
        successCallBack(urlResponse.result.value as AnyObject, requestId)
    }
    
    //MARK: helper method
    func generateRequestId() -> NSNumber {
        
        guard let requestOrder = latestStoredRequestId else {
            latestStoredRequestId =
                
                NSNumber(value: 1)
            return latestStoredRequestId!
        }
        
        guard requestOrder.intValue < NSIntegerMax && requestOrder.intValue > 0 else {
            latestStoredRequestId = NSNumber(value: 1)
            return latestStoredRequestId!
        }
        
        latestStoredRequestId = NSNumber(value: requestOrder.intValue + 1);
        return latestStoredRequestId!;
    }
    
    //MARK: - life cycle
    deinit {
        self.cancellAllRequest()
    }
    
    //MARK: variables
    var latestStoredRequestId: NSNumber?
    var storedRequests = Dictionary<NSNumber, Request>()
    
    //singleton instance
//    private static var onceToken: dispatch_once_t = 0

    
    static let  sharedInstance = ApiProxy()
}
