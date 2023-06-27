//
//  ViewController.swift
//  The Memory
//
//  Created by Andrei on 14/6/23.
//

import UIKit


protocol GameVCProtocol: AnyObject {
    func endGame()
}

class GameViewController: UIViewController, GameVCProtocol {
    
    private var restartButton = UIButton()
    private var timerView = TimerView()
    private var menuButton = UIButton()
    
    private var collectionView = CardsCollectionView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9753940701, green: 0.9080986381, blue: 0.9533265233, alpha: 1)
        collectionView.gameVCdelegate = self
        
        view.addSubview(timerView)
        view.addSubview(collectionView)
        
        view.addSubview(restartButton)
        view.addSubview(menuButton)
        
        setupTimerView()
        setupCollectionView()
        setupRestartButton()
        setupMenuButton()
        
   
        NotificationCenter.default.addObserver(self, selector: #selector(pauseTimer), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
   @objc func pauseTimer() {
        timerView.startStopTimer()
    }
    
   @objc func resumeTimer() {
        timerView.startStopTimer()
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
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
        
            self.collectionView.fetchImages()
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutSubviews()
        
            self.timerView.startStopTimer()
        }
    }
    
    private func saveGame(time: String) {
        StorageManager.shared.saveTime(time) { time in
            print(time)
        }
    }
    
    
    @objc func goToMenu() -> Void {
        let sceneDelegate = SceneDelegate.shared
        sceneDelegate?.window?.rootViewController = MenuViewController()
    }
    
    private func setupTimerView() {
        timerView.translatesAutoresizingMaskIntoConstraints = false
        timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timerView.centerYAnchor.constraint(equalTo: restartButton.centerYAnchor).isActive = true
        timerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        timerView.widthAnchor.constraint(equalToConstant: 110).isActive = true
        timerView.backgroundColor = #colorLiteral(red: 1, green: 0.7603909373, blue: 0.9043188095, alpha: 1)
        timerView.layer.cornerRadius = 10
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView.collectionViewLayout = layout
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
    }


    private func setupRestartButton() {
        restartButton.setTitle("RESTART", for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        restartButton.setTitleColor(.systemPurple, for: .normal)
        restartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartButton.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -40),
            restartButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
            
        ])
    }
    
    private func setupMenuButton() {
        menuButton.setTitle("MENU", for: .normal)
        menuButton.addTarget(self, action: #selector(goToMenu), for: .touchUpInside)
        menuButton.setTitleColor(.systemPurple, for: .normal)
        menuButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
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



