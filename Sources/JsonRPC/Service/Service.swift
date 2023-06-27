//
//  File.swift
//  
//
//  Created by Daniel Leping on 19/12/2020.
//

import Foundation

public enum ServiceError: Swift.Error {
    case connection(cause: ConnectionError)
    case codec(cause: CodecError)
    case envelope(header: EnvelopeHeader, description: String)
    case unregisteredResponse(id: RPCID, body: Data)
}

public class Service<Core: ServiceCoreProtocol> {
    private var core: Core
    private let caller: Callable
    
    init(core: Core, caller: Callable) {
        self.core = core
        self.caller = caller
    }
}

extension Service: Client {
    public var debug: Bool {
        get { core.debug }
        set { core.debug = newValue }
    }
    
    public func call<Params: Encodable, Res: Decodable, Err: Decodable>(
        method: String, params: Params, _ res: Res.Type, _ err: Err.Type,
        response callback: @escaping RequestCallback<Params, Res, Err>
    ) {
        caller.call(method: method, params: params, res, err, response: callback)
    }
}

extension Service: Persistent where Core.Delegate == AnyObject {
    public var delegate: AnyObject? {
        get {
            core.delegate
        }
        set {
            core.delegate = newValue
        }
    }
}

extension Service: Connectable where Core: Connectable {
    public var connected: ConnectableState {
        core.connected
    }
    
    public func connect() {
        core.connect()
    }
    
    public func disconnect() {
        core.disconnect()
    }
}

extension Service: ContentCodersProvider where Core: ContentCodersProvider {
    public var contentDecoder: ContentDecoder {
        get { core.contentDecoder }
        set { core.contentDecoder = newValue }
    }
    
    public var contentEncoder: ContentEncoder {
        get { core.contentEncoder }
        set { core.contentEncoder = newValue }
    }
}