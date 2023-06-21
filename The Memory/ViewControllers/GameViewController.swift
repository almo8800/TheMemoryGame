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
    
    
    var collectionView = CardsCollectionView()
    
    var restartButton = UIButton()
    var menuButton = UIButton()
    
    var timerLabel = UILabel()
    var timer: Timer = Timer()
    var count: Int = 0
    var timerCountring: Bool = false
    
    var timerCounting: Bool = false
    
    let myRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        return refreshControl
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.9753940701, green: 0.9080986381, blue: 0.9533265233, alpha: 1)
        collectionView.gameVCdelegate = self
        
        timerLabel.text = "00 : 00 : 00"
        timerLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        view.addSubview(collectionView)
        view.addSubview(timerLabel)
        view.addSubview(restartButton)
        view.addSubview(menuButton)
        
        restartButton.setTitle("RESTART", for: .normal)
        restartButton.addTarget(self, action: #selector(restartGame), for: .touchUpInside)
        restartButton.setTitleColor(.systemPurple, for: .normal)
        restartButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        menuButton.setTitle("MENU", for: .normal)
        menuButton.addTarget(self, action: #selector(goToMenu), for: .touchUpInside)
        menuButton.setTitleColor(.systemPurple, for: .normal)
        menuButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        
        setUpConstraints()
     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startStopTimer()
    }
    
    func endGame() {
        print("game end")
        saveGame(time: timerLabel.text ?? "no timerLabel.text")
        restartGame()
        
    }
    
    @objc func restartGame() -> Void {
    
        collectionView.openCards = 0
        collectionView.setBackAllCellLogic()
        collectionView.firstFlippedCardIndex = nil
        collectionView.firstFlippedCardTag = nil
        
        resetTimer()
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            CardsGenerator.shared.fillArrayForGame(level: HardLevel.four.rawValue)
            self.collectionView.imageArray = CardsGenerator.shared.arrayForGame
            
            print("new game array \(self.collectionView.imageArray)")
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutSubviews()
            
            self.startStopTimer()
            
        }
        
    }
    
    @objc func goToMenu() -> Void {
        let sceneDelegate = SceneDelegate.shared
        sceneDelegate?.window?.rootViewController = MenuViewController()
    }
    
    private func saveGame(time: String) {
        StorageManager.shared.saveTime(time) { [unowned self] time in
            print(time)
        }
    }
    
    
    func resetTimer() {
        self.count = 0
        self.timer.invalidate()
        self.timerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
        self.timerCounting = false
    }
    
    func startStopTimer() {
        
        if(timerCounting) {
            timerCounting = false
            timer.invalidate()
        } else {
            timerCounting = true
            timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(timerCounter),
                userInfo: nil,
                repeats: true)
        }
    }
    
    @objc func timerCounter() -> Void {
        
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
        
    }
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)

        return timeString
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setCollectionLayout()
        setUpTimerLayour()
        setupRestartButton()
        setupMenuButton()
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
    
    private func setUpTimerLayour() {
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timerLabel.centerYAnchor.constraint(equalTo: restartButton.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
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



