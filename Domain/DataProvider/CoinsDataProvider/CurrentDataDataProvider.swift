//
//  CurrentDataDataProvider.swift
//  MarketCoins
//
//  Created by Igor Fortti on 08/09/23.
//

import Foundation

protocol CurrentDataDataProviderDelegate: GenericDataProviderDelegate { }

class CurrentDataDataProvider: DataProviderManager<CurrentDataDataProviderDelegate, CurrentDataModel> {
    
    private let coinStore: CoinsStoreProtocol?
    
    init(coinStore: CoinsStoreProtocol = CoinsStore()) {
        self.coinStore = coinStore
    }
    
    func fetchCoin(by id: String) {
        coinStore?.fetchCoin(by: id, completion: { result, error in
            if let error = error {
                self.delegate?.errorData(self.delegate, error: error)
            }
            
            if let result = result {
                self.delegate?.success(model: result)
            }
        })
    }
    
}
