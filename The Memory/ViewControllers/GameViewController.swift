//
//  ViewController.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit


protocol GameVCDelegate {
    func endGame()
}

class GameViewController: UIViewController, GameVCDelegate {
    
    var restartButton = UIButton()
    var timerView = TimerView()
    var menuButton = UIButton()
    
    var collectionView = CardsCollectionView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9753940701, green: 0.9080986381, blue: 0.9533265233, alpha: 1)
        collectionView.gameVCdelegate = self
        
        view.addSubview(timerView)
        view.addSubview(collectionView)
        
        view.addSubview(restartButton)
        view.addSubview(menuButton)
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timerView.centerYAnchor.constraint(equalTo: restartButton.centerYAnchor).isActive = true
        timerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        timerView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        timerView.backgroundColor = #colorLiteral(red: 1, green: 0.7603909373, blue: 0.9043188095, alpha: 1)
        timerView.layer.cornerRadius = 10
        
        restartButton.setTitle("RESTART", for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        restartButton.setTitleColor(.systemPurple, for: .normal)
        restartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        menuButton.setTitle("MENU", for: .normal)
        menuButton.addTarget(self, action: #selector(goToMenu), for: .touchUpInside)
        menuButton.setTitleColor(.systemPurple, for: .normal)
        menuButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        setUpConstraints()
        setCollectionLayout()
        setupRestartButton()
        setupMenuButton()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerView.startStopTimer()
    }
    
    internal func endGame() {
        print("game end")
        saveGame(time: timerView.timerLabel.text ?? "no timerLabel.text")
        restartGame()
        
    }
    
    @objc func restartGame() -> Void {
        
        collectionView.openCards = 0
        collectionView.setBackAllCellLogic()
        collectionView.firstFlippedCardIndex = nil
        collectionView.firstFlippedCardTag = nil
        
        timerView.resetTimer()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            //CardsGenerator.shared.fillArrayForGame()
            self.collectionView.fetchImages()
            
            print("new game array \(self.collectionView.imageArray)")
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutSubviews()
            
            
            self.timerView.startStopTimer()
        }
    }
    
    private func saveGame(time: String) {
        StorageManager.shared.saveTime(time) { [unowned self] time in
            print(time)
        }
    }
    
    
    @objc func goToMenu() -> Void {
        let sceneDelegate = SceneDelegate.shared
        sceneDelegate?.window?.rootViewController = MenuViewController()
    }
    
    private func setUpConstraints() {
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80)
        ])
    }
    
    private func setCollectionLayout() {
        let layout = UICollectionViewFlowLayout()
        let itemWidth = (collectionView.frame.width - layout.minimumInteritemSpacing * 3) / 4
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout
    }
    
    
    
    private func setupRestartButton() {
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -40),
            restartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            
        ])
    }
    
    private func setupMenuButton() {
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -40),
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            
        ])
    }
    
    deinit {
        print("GameViewController DEINIT")
    }
}



