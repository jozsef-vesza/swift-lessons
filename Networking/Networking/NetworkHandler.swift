//
//  NetworkHandler.swift
//  Networking
//
//  Created by József Vesza on 09/11/14.
//  Copyright (c) 2014 Jozsef Vesza. All rights reserved.
//

import Foundation

typealias CallbackBlock = (String, String?) -> Void
typealias CompleteHandlerBlock = () -> ()

struct SessionProperties {
    static let idenfifier: String = "url_session_background_download"
    static let uploadIdentifier: String = "url_session_foreground_upload"
}

class NetworkHandler: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate , NSURLSessionDownloadDelegate, NSURLSessionDataDelegate {
    
    var handlerQueue: [String : CompleteHandlerBlock]!
    var uploadQueue: [String : NSURLSessionTask]!
    var uploadCompletionHandler: CallbackBlock!
    var responsedata = NSMutableData()
    
    class var sharedInstance: NetworkHandler {
        struct Static {
            static var instance: NetworkHandler?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = NetworkHandler()
            Static.instance!.handlerQueue = [String : CompleteHandlerBlock]()
            Static.instance!.uploadQueue = [String : NSURLSessionTask]()
        }
        
        return Static.instance!
    }
    
    func httpGet(request: NSMutableURLRequest, callback: CallbackBlock) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                callback("", error.localizedDescription)
            } else {
                if let result = NSString(data: data, encoding: NSASCIIStringEncoding) {
                    callback(result, nil)
                }
            }
        }
        task.resume()
    }
    
    func startBackgroundDownload(request: NSMutableURLRequest) {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(SessionProperties.idenfifier)
        let backgroundSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let downloadTask = backgroundSession.downloadTaskWithRequest(request)
        downloadTask.resume()
    }
    
    func startUpload(request: NSMutableURLRequest, data: NSData, completion: CallbackBlock) {
        uploadCompletionHandler = completion
        request.HTTPMethod = "POST"
        request.setValue("Keep-Alive", forHTTPHeaderField: "Connection")
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let task = session.uploadTaskWithRequest(request, fromData: data)
        uploadQueue[SessionProperties.uploadIdentifier] = task
        task.resume()
    }
    
    // MARK: session delegate
    
    func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        println("Session error: \(error?.localizedDescription)")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
        println("Challenge: \(challenge)")
        completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, NSURLCredential(forTrust: challenge.protectionSpace.serverTrust))
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
        println("New request: \(request.description)")
        completionHandler(request)
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        println("session \(session) has finished the download task \(downloadTask) of URL \(location).")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
         println("session \(session) download task \(downloadTask) wrote an additional \(bytesWritten) bytes (total \(totalBytesWritten) bytes) out of an expected \(totalBytesExpectedToWrite) bytes.")
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        println("session \(session) download task \(downloadTask) resumed at offset \(fileOffset) bytes out of an expected \(expectedTotalBytes) bytes.")
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if task == uploadQueue[SessionProperties.uploadIdentifier] {
            if error != nil {
                let errorDescription = error?.localizedDescription
                println("session \(session) upload failed with error: \(errorDescription)")
                uploadCompletionHandler("", errorDescription)
            } else {
                let response = NSString(data: responsedata, encoding: NSUTF8StringEncoding)
                println("session \(session) upload completed, response:\(responsedata)")
                uploadCompletionHandler(response!, nil)
            }
            
            uploadQueue.removeValueForKey(SessionProperties.uploadIdentifier)
            uploadCompletionHandler = nil
            
        } else {
            if error == nil {
                println("session \(session) download completed")
            } else {
                println("session \(session) download failed with error \(error?.localizedDescription)")
            }
        }
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
        println("session \(session) uploaded \(progress * 100)%")
        uploadCompletionHandler("\(progress * 100)%", nil)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        println("session \(session) received response: \(response)")
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        responsedata.appendData(data)
    }
    
    // MARK: Background session handling
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        println("background session \(session) finished events.")
        
        if !session.configuration.identifier.isEmpty {
            callCompletionHandlerForSession(session.configuration.identifier)
        }
    }
    
    func addCompletionHandler(handler: CompleteHandlerBlock, identifier: String) {
        handlerQueue[identifier] = handler
    }
    
    func callCompletionHandlerForSession(identifier: String!) {
        if let handler = handlerQueue[identifier] {
            handlerQueue.removeValueForKey(identifier)
            handler()
        }
    }
}