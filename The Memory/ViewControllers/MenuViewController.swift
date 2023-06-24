//
//  MenuViewController.swift
//  The Memory
//
//  Created by Andrei on 20/6/23.
//
import Foundation
import UIKit
import CoreData

class MenuViewController: UIViewController {
    

    
    private var numberOfCardsinGame = 16 {
        didSet {
            CardsGenerator.shared.cardsNumber = numberOfCardsinGame
        }
    }
    
    private var levelTitle: UILabel = {
        let label = UILabel()
        label.text = "Gameboard size"
        return label
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: DifficultyLevel.allValues())
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(levelHasChanged), for: .valueChanged)
        return view
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("START GAME", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = #colorLiteral(red: 0.9669273496, green: 0.7500750422, blue: 0.9268592, alpha: 1)
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    
    
    var gameStatLabel: UILabel {
        let label = UILabel()
        label.text = "TOP 3 RESULTS"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }
    
    var firstTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        
        return label
    }()
    
    var secondTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        return label
    }()
    
    var thirdsTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        return label
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("DELETE", for: .normal)
        button.addTarget(MenuViewController.self, action: #selector(deleteAllStats), for: .touchUpInside)
        
        return button
    }()
    
    var timeArray: [GameTime] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        
        addLevelStack()
        addStatiscticStack()
        addStartButton()
        
        fetchStat()
        sortStat()
    }
    
    private func addLevelStack() {
        let levelStackView = UIStackView(arrangedSubviews: [levelTitle, segmentedControl])
        levelStackView.axis = .horizontal
        levelStackView.spacing = 10
        levelStackView.alignment = .center
        
        view.addSubview(levelStackView)
        levelStackView.translatesAutoresizingMaskIntoConstraints = false
        levelStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        levelStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150).isActive = true
        
        segmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        segmentedControl.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func addStatiscticStack() {
        let labelsStackView = UIStackView(arrangedSubviews: [gameStatLabel, firstTimeLabel, secondTimeLabel, thirdsTimeLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        labelsStackView.alignment = .center
        view.addSubview(labelsStackView)
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelsStackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 50).isActive = true
    }
    
    private func addStartButton() {
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: thirdsTimeLabel.topAnchor, constant: 80),
            startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    @objc func startButtonTapped() {
        let sceneDelegate = SceneDelegate.shared
        sceneDelegate?.window?.rootViewController = GameViewController()
        
    }
    
    @objc func levelHasChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            numberOfCardsinGame = DifficultyLevel.fourXfour.rawValue
        case 1:
            numberOfCardsinGame = DifficultyLevel.fourXsix.rawValue
        default:
            print("level high default")
        }
    }
    
    private func fetchStat() {
        StorageManager.shared.fetchData { [unowned self] result in
            switch result {
            case .success(let timeList):
                self.timeArray = timeList
                print(self.timeArray)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func sortStat() {
        let sortedTime = timeArray.sorted { (time1, time2) -> Bool in
            
            let components1 = time1.time?.components(separatedBy: " : ")
            let components2 = time2.time?.components(separatedBy: " : ")
            
            guard components1?.count == 3 && components2?.count == 3 else {
                return false
            }
            
            let seconds1 = Int(components1![0])! * 3600 + Int(components1![1])! * 60 + Int((components1?[2])!)!
            let seconds2 = Int(components2![0])! * 3600 + Int(components2![1])! * 60 + Int((components2?[2])!)!
            
            return seconds1 < seconds2
        }
        
        if sortedTime.count == 1 {
            self.firstTimeLabel.text = sortedTime[0].time
        } else if
            sortedTime.count == 2 {
            self.firstTimeLabel.text = sortedTime[0].time
            self.secondTimeLabel.text = sortedTime[1].time
        } else if
            sortedTime.count >= 3 {
            self.firstTimeLabel.text = sortedTime[0].time
            self.secondTimeLabel.text = sortedTime[1].time
            self.thirdsTimeLabel.text = sortedTime[2].time
        }
    }
    
    @objc func deleteAllStats() {
        StorageManager.shared.deleteStats()
    }
    
    func presentAlert() {
        let alertController = UIAlertController(title: "Alert", message: "На телефоне должно быть как минимум 12 уникальных фотографий / видео", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
}
