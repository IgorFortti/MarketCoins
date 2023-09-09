//
//  GlobalStore.swift
//  MarketCoins
//
//  Created by Igor Fortti on 08/09/23.
//

import Foundation

protocol GlobalStoreProtocol: GenericStoreProtocol {
    func fetchGlobal(completion: @escaping completion<GlobalModel?>)
}

class GloblalStore: GenericStoreRequest, GlobalStoreProtocol {
    
    func fetchGlobal(completion: @escaping completion<GlobalModel?>) {
        do {
            guard let url = try GlobalRouter.global.asURLRequest() else {
                return completion(nil, error)
            }
            request(url: url, completion: completion)
        } catch let error {
            completion(nil, error)
        }
    }
}
