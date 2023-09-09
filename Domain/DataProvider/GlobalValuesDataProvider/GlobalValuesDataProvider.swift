//
//  GlobalValuesDataProvider.swift
//  MarketCoins
//
//  Created by Igor Fortti on 08/09/23.
//

import Foundation

protocol GlobalValuesDataProviderDelegate: GenericDataProviderDelegate {}

class GlobalValuesDataProvider: DataProviderManager<GlobalValuesDataProviderDelegate, GlobalModel> {
    
    private let globalStore: GlobalStoreProtocol?
    
    init(globalStore: GlobalStoreProtocol = GloblalStore()) {
        self.globalStore = globalStore
    }
    
    func fetchGlobalValues() {
        globalStore?.fetchGlobal(completion: { result, error in
            if let error = error {
                self.delegate?.errorData(self.delegate, error: error)
            }
            
            if let result = result {
                self.delegate?.success(model: result)
            }
        })
    }
    
}
