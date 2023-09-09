//
//  MarketChartDataProvider.swift
//  MarketCoins
//
//  Created by Igor Fortti on 08/09/23.
//

import Foundation

protocol MarketChartDataProviderDelegate: GenericDataProviderDelegate { }

class MarketChartDataProvider: DataProviderManager<MarketChartDataProviderDelegate, MarketDataModel> {
    
    private let coinStore: CoinsStoreProtocol?
    
    init(coinStore: CoinsStoreProtocol = CoinsStore()) {
        self.coinStore = coinStore
    }
    
    func fetchMarketChartRange(by id: String, currency: String, from: String, to: String) {
        coinStore?.fetchHistorical(by: id, currency: currency, from: from, to: to, completion: { result, error in
            if let error = error {
                self.delegate?.errorData(self.delegate, error: error)
            }
            
            if let result = result {
                self.delegate?.success(model: result)
            }
        })
    }
}
