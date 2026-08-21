//
//  PulseNetworkLogging.swift
//  EstacioneAqui
//


import Alamofire
import Foundation

#if DEBUG

import Pulse

struct PulseEventMonitor: EventMonitor {
    var logger: NetworkLogger = .shared

    func request(_ request: Request, didCreateTask task: URLSessionTask) {
        logger.logTaskCreated(task)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        logger.logDataTask(dataTask, didReceive: data)
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didFinishCollecting metrics: URLSessionTaskMetrics
    ) {
        logger.logTask(task, didFinishCollecting: metrics)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        logger.logTask(task, didCompleteWithError: error)
    }
}

#endif

extension Session {
    static let estacioneAqui: Session = {
        #if DEBUG
        Session(eventMonitors: [PulseEventMonitor()])
        #else
        .default
        #endif
    }()
}
