//
//  CoinsListInteractor.swift
//  MarketCoins
//
//  Created by Igor Fortti on 08/09/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CoinsListBusinessLogic {
    func doFetchGlobalValues(request: CoinsList.FetchGlobalValues.Request)
    func doFetchListCoins(request: CoinsList.FetchListCoins.Request)
}

protocol CoinsListDataStore {
    var coins: [CoinModel]? { get set }
}

class CoinsListInteractor: CoinsListBusinessLogic, CoinsListDataStore {
    
    var presenter: CoinsListPresentationLogic?
    var globalValuesWorker: GlobalValuesWorker?
    var coinListWorker: CoinsListWorker?
    var coins: [CoinModel]?
    
    init(presenter: CoinsListPresentationLogic = CoinsListPresenter(),
         globalValuesWorker: GlobalValuesWorker = GlobalValuesWorker(),
         coinListWorker: CoinsListWorker = CoinsListWorker()) {
        
        self.presenter = presenter
        self.globalValuesWorker = globalValuesWorker
        self.coinListWorker = coinListWorker
    }
    
    func doFetchGlobalValues(request: CoinsList.FetchGlobalValues.Request) {
        globalValuesWorker?.doFetchGlobalValues(completion: { result in
            switch result {
            case .success(let globalModel):
                self.createGlobalValuesResponse(baseCoin: request.baseCoin, global: globalModel)
            case .failure:
                self.presenter?.presentErrorForGlobalValues(baseCoin: request.baseCoin)
            }
        })
    }
    
    func doFetchListCoins(request: CoinsList.FetchListCoins.Request) {
        let baseCoin = request.baseCoin.rawValue
        let orderBy = request.orderBy.rawValue
        let top = request.top.rawValue
        let percentagePrice = request.princePercentage.rawValue
        
        coinListWorker?.doFetchListCoins(baseCoin: baseCoin,
                                         orderBy: orderBy,
                                         top: top,
                                         percentagePrice: percentagePrice,
                                         completion: { result in
            switch result {
            case .success(let listCoinsModel):
                self.coins = listCoinsModel
                self.createListCoinsResponse(request: request, listCoins: listCoinsModel)
            case .failure(let error):
                self.presenter?.presentError(error: error)
            }
        })
    }
    
    private func createGlobalValuesResponse(baseCoin: CoinsFilterEnum, global: GlobalModel?) {
        if let global = global {
            let totalMarketCap = global.data.totalMarketCap.filter { $0.key == baseCoin.rawValue }
            let totalVolume = global.data.totalVolume.filter { $0.key == baseCoin.rawValue }
            let changePercentage = global.data.marketCapChangePercentage24HUsd

            let response = CoinsList.FetchGlobalValues.Response(
                baseCoin: baseCoin,
                totalMarketCap: totalMarketCap,
                totalVolume: totalVolume,
                changePercentage: changePercentage
            )

            presenter?.presentGlobalValues(response: response)
        } else {
            presenter?.presentErrorForGlobalValues(baseCoin: baseCoin)
        }
    }
    
    private func createListCoinsResponse(request: CoinsList.FetchListCoins.Request, listCoins: [CoinModel]?) {
        if let listCoins = listCoins {
            func priceChangePercentage(pricePercentage: PriceChangePercentageFilterEnum, coin: CoinModel) -> Double {
                switch pricePercentage {
                case .lastHour:
                    return coin.priceChangePercentage1H ?? 0.0
                case .oneDay:
                    return coin.priceChangePercentage24H ?? 0.0
                case .oneWeek:
                    return coin.priceChangePercentage7D ?? 0.0
                case .oneMonth:
                    return coin.priceChangePercentage30D ?? 0.0
                }
            }
            
            let response = listCoins.map { coin in
                return CoinsList.FetchListCoins.Response(
                    baseCoin: request.baseCoin,
                    id: coin.id,
                    symbol: coin.symbol,
                    name: coin.name,
                    image: coin.image,
                    currentPrice: coin.currentPrice ?? 0.0,
                    marketCap: coin.marketCap ?? 0.0,
                    marketCapRank: coin.marketCapRank,
                    priceChangePercentage: priceChangePercentage(
                        pricePercentage: request.princePercentage,
                        coin: coin
                    )
                )
            }
            
            presenter?.presentListCoins(response: response)
        } else {
            presenter?.presentError(error: .undefinedError)
        }
    }
}
