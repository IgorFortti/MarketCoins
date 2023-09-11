//
//  CoinInteractor.swift
//  MarketCoins
//
//  Created by Igor Fortti on 11/09/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol CoinBusinessLogic
{
  func doSomething(request: Coin.Something.Request)
}

protocol CoinDataStore
{
  //var name: String { get set }
}

class CoinInteractor: CoinBusinessLogic, CoinDataStore
{
  var presenter: CoinPresentationLogic?
  var worker: CoinWorker?
  //var name: String = ""
  
  // MARK: Do something
  
  func doSomething(request: Coin.Something.Request)
  {
    worker = CoinWorker()
    worker?.doSomeWork()
    
    let response = Coin.Something.Response()
    presenter?.presentSomething(response: response)
  }
}
