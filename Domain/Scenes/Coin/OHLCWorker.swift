//
//  OHLCWorker.swift
//  MarketCoins
//
//  Created by Igor Fortti on 11/09/23.
//

import UIKit


class OHLCWorker {
    
    private let dataProvider: OHLCDataProvider?
    private var completion: ((Result<[GraphicDataModel]?, KarketCoinsError>) -> Void)?
    
    init(dataProvider: OHLCDataProvider = OHLCDataProvider()) {
        self.dataProvider = dataProvider
        self.dataProvider?.delegate = self
    }
    
    func doFetchMarketChart(id: String,
                            baseCoin: String,
                            of: String,
                            completion: @escaping ((Result<[GraphicDataModel]?, KarketCoinsError>) -> Void)) {
        dataProvider?.fetchOhlc(by: id, currency: baseCoin, of: of)
        self.completion = completion
    }
}

extension OHLCWorker: OHLCDataProviderDelegate {
    
    func success(model: Any) {
        guard let completion = completion else {
            fatalError("Completion not implemented!")
        }
        completion(.success(model as? [GraphicDataModel]))
    }
    
    func errorData(_ provider: GenericDataProviderDelegate?, error: Error) {
        guard let completion = completion else {
            fatalError("Completion not implemented!")
        }
        
        if error.errorCode == 500 {
            completion(.failure(.internalServerError))
        } else if error.errorCode == 400 {
            completion(.failure(.badRequestError))
        } else if error.errorCode == 404 {
            completion(.failure(.notFoundError))
        } else {
            completion(.failure(.undefinedError))
        }
    }
}
