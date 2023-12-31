//
//  CoinsListViewController.swift
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

protocol CoinsListDisplayLogic: AnyObject {
    func displayGlobalValues(viewModel: CoinsList.FetchGlobalValues.ViewModel)
    func displayListCoins(viewModel: CoinsList.FetchListCoins.ViewModel)
    func displayError(error: String)
}

class CoinsListViewController: ViewController {
    
    @IBOutlet weak var globalView: UIView!
    
    @IBOutlet weak var globalCollectionView: UICollectionView! {
        didSet {
            globalCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var filterCollectionView: UICollectionView! {
        didSet {
            filterCollectionView.delegate = self
            filterCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var listCoinsTableView: UITableView! {
        didSet {
            listCoinsTableView.delegate = self
            listCoinsTableView.dataSource = self
        }
    }
    
    private lazy var coinsFilterView: FiltersView = {
        let filterView = FiltersView()
        filterView.isHidden = true
        filterView.delegate = self
        filterView.filterOptions = filtersUtils.coinsFilter
        return filterView
    }()
    
    private lazy var topFilterView: FiltersView = {
        let filterView = FiltersView()
        filterView.isHidden = true
        filterView.delegate = self
        filterView.filterOptions = filtersUtils.topFilter
        return filterView
    }()
    
    private lazy var priceChangePercentageFilterView: FiltersView = {
        let filterView = FiltersView()
        filterView.isHidden = true
        filterView.delegate = self
        filterView.filterOptions = filtersUtils.priceChangePercentageFilter
        return filterView
    }()
    
    private lazy var orderByFilterView: FiltersView = {
        let filterView = FiltersView()
        filterView.isHidden = true
        filterView.delegate = self
        filterView.filterOptions = filtersUtils.orderByFilter
        return filterView
    }()
    
    private var globalViewModel: CoinsList.FetchGlobalValues.ViewModel?
    private var coinsViewModel: CoinsList.FetchListCoins.ViewModel?
    private let filtersUtils = FiltersUtils.shared
    
    var interactor: CoinsListBusinessLogic?
    var router: (NSObjectProtocol & CoinsListRoutingLogic & CoinsListDataPassing)?
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubviews(coinsFilterView, topFilterView, priceChangePercentageFilterView, orderByFilterView)
        
        let nib = UINib(nibName: CoinHeaderView.identifier, bundle: nil)
        listCoinsTableView.register(nib, forHeaderFooterViewReuseIdentifier: CoinHeaderView.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCoinFilter()
        
        doFetchGlobalValues()
        doFetchListCoins()
        filterCollectionView.reloadData()
    }
    
    // MARK: Setup
    
    override func setup() {
        let viewController = self
        let interactor = CoinsListInteractor()
        let presenter = CoinsListPresenter()
        let router = CoinsListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    func setupCoinFilter() {
        let filter = filtersUtils.getSelectedCoinsFilter()
        switch filter {
        case .brl:
            coinsFilterView.filterPickerView.selectRow(0, inComponent: 0, animated: true)
        case .usd:
            coinsFilterView.filterPickerView.selectRow(1, inComponent: 0, animated: true)
        case .eur:
            coinsFilterView.filterPickerView.selectRow(2, inComponent: 0, animated: true)
        }
    }
    
    func doFetchGlobalValues() {
        globalCollectionView.isHidden = true
        MarketCoinsLoading.shared.start(from: globalView, isBackground: false, isLarge: false)
        
        let baseCoin = filtersUtils.getSelectedCoinsFilter()
        let request = CoinsList.FetchGlobalValues.Request(baseCoin: baseCoin)
        interactor?.doFetchGlobalValues(request: request)
    }
    
    func doFetchListCoins() {
        listCoinsTableView.isHidden = true
        MarketCoinsLoading.shared.start(from: view)
        
        let request = CoinsList.FetchListCoins.Request(
            baseCoin: filtersUtils.getSelectedCoinsFilter(),
            orderBy: filtersUtils.getSelectedOrderByFilter(),
            top: filtersUtils.getSelectedTopFilter(),
            princePercentage: filtersUtils.getSelectedPriceChangePercentageFilter()
        )
        interactor?.doFetchListCoins(request: request)
    }
}

extension CoinsListViewController: CoinsListDisplayLogic {
    
    func displayGlobalValues(viewModel: CoinsList.FetchGlobalValues.ViewModel) {
        globalViewModel = viewModel
        
        DispatchQueue.main.async {
            self.globalCollectionView.reloadData()
            
            self.globalCollectionView.isHidden = false
            MarketCoinsLoading.shared.stop(from: self.globalView)
        }
    }
    
    func displayListCoins(viewModel: CoinsList.FetchListCoins.ViewModel) {
        coinsViewModel = viewModel
        
        DispatchQueue.main.async {
            self.listCoinsTableView.reloadData()
            
            self.listCoinsTableView.isHidden = false
            MarketCoinsLoading.shared.stop(from: self.view)
        }
    }
    
    func displayError(error: String) {
        DispatchQueue.main.async {
            MarketCoinsLoading.shared.stop(from: self.view)
            self.showError(for: error) { _ in
                self.doFetchListCoins()
            }
        }
    }
}

extension CoinsListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filtersUtils.displayedFilters[indexPath.row]
        
        if filtersUtils.coinsFilter.contains(where: { $0.type == selectedFilter.type }) {
            coinsFilterView.cellRow = indexPath.row
            showFilterPickerView(coinsFilterView)
        }
        
        if filtersUtils.topFilter.contains(where: { $0.type == selectedFilter.type }) {
            topFilterView.cellRow = indexPath.row
            showFilterPickerView(topFilterView)
        }
        
        if filtersUtils.priceChangePercentageFilter.contains(where: { $0.type == selectedFilter.type }) {
            priceChangePercentageFilterView.cellRow = indexPath.row
            showFilterPickerView(priceChangePercentageFilterView)
        }
        
        if filtersUtils.orderByFilter.contains(where: { $0.type == selectedFilter.type }) {
            orderByFilterView.cellRow = indexPath.row
            showFilterPickerView(orderByFilterView)
        }
    }
    
    private func showFilterPickerView(_ filterPickerView: FiltersView) {
        UIView.transition(with: filterPickerView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            filterPickerView.isHidden = false
        })

    }
}

extension CoinsListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == globalCollectionView {
            return globalViewModel?.globalValues.count ?? 0
        }
        return filtersUtils.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == globalCollectionView {
            guard let viewModel = globalViewModel else { return UICollectionViewCell() }
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GlobalValuesViewCell.indentifier, for: indexPath) as? GlobalValuesViewCell {
                
                let glovalValues = viewModel.globalValues[indexPath.row]
                cell.titleLabel.text = glovalValues.title
                cell.valueLabel.attributedText = glovalValues.value
                
                return cell
            }
        }
        
        if collectionView == filterCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterViewCell.indentifier, for: indexPath) as? FilterViewCell {
                let displayedFilter = filtersUtils.displayedFilters[indexPath.row]
                cell.setupCell(filter: displayedFilter)
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
}

extension CoinsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CoinHeaderView.identifier) as? CoinHeaderView {
            
            if let filter = filtersUtils.displayedFilters.filter({ $0.type == .priceChangePercentage }).first {
                header.setupPriceChangePergentage(from: filter)
            }
            
            return header
        }
        return UIView()
    }
}

extension CoinsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinsViewModel?.coins.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: CoinViewCell.indentifier, for: indexPath) as? CoinViewCell {
            
            guard let viewModel = coinsViewModel else { return UITableViewCell() }
            
            let coin = viewModel.coins[indexPath.row]
            cell.rankLabel.text = coin.rank
            cell.iconImageView.loadImage(from: coin.iconUrl)
            cell.symbilLabel.text = coin.symbol
            cell.priceLabel.text = coin.price
            cell.percentageLabel.attributedText = coin.priceChangePercentage
            cell.marketCapitalizationLabel.text = coin.marketCapitalization
            
            return cell
        }
        
        return UITableViewCell()
    }
}

extension CoinsListViewController: ToolbarFiltersViewDelegate {
    
    func filtersView(_ filtersView: FiltersView, didSelect filter: Filter, forCellRow row: Int) {
        filtersUtils.setSelectedFilter(to: filter, of: row)
        
        filterCollectionView.reloadData()
        
        doFetchGlobalValues()
        doFetchListCoins()
        
        cancelFilter(for: filtersView)
    }
    
    func cancelFilter(for filtersView: FiltersView) {
        UIView.transition(with: filtersView, duration: 0.5, options: .transitionCrossDissolve) {
            filtersView.isHidden = true
        }
    }
}
