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
    
    private var difficultyLevel = CardsGenerator.shared.difficultyLevel {
        didSet {
            CardsGenerator.shared.difficultyLevel = difficultyLevel
        }
    }
    
    private var levelTitle: UILabel = {
        let label = UILabel()
        label.text = "Gameboard size"
        return label
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: DifficultyLevel.allValues())
        view.selectedSegmentIndex = difficultyLevel == .fourXfour ? 0 : 1
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
    
    private var firstTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        
        return label
    }()
    
    private var secondTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        return label
    }()
    
    private var thirdsTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "play more games"
        return label
    }()
    
    private var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.setTitle("DELETE", for: .normal)
        button.addTarget(MenuViewController.self, action: #selector(deleteAllStats), for: .touchUpInside)
        
        return button
    }()
    
    private var timeArray: [GameTime] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        
        addLevelStack()
        addStatiscticStack()
        addStartButton()
        
        fetchStatistics()
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
        CardsGenerator.shared.checkAccessToLib { status, assetsCount in
            
            switch status {
            case .authorized:
                DispatchQueue.main.async {
                    if assetsCount < 12 {
                        self.presentAlertQuantity()
                    } else {
                        let sceneDelegate = SceneDelegate.shared
                        sceneDelegate?.window?.rootViewController = GameViewController()
                        return
                    }
                 
                }
     
            case .notDetermined, .restricted, .denied, .limited:
                DispatchQueue.main.async {
                    self.presentAlertAccess()
                }
            @unknown default:
                fatalError()
            }
        }
        
        
    }
    
    @objc func levelHasChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            difficultyLevel = DifficultyLevel.fourXfour
        case 1:
            difficultyLevel = DifficultyLevel.fourXsix
        default:
            print("level high default")
        }
    }
    
    private func fetchStatistics() {
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
    
    private func presentAlertAccess() {
        let alertController = UIAlertController(title: "Будем играть с твоими фото", message: "Предоставьте полный доступ к своей библиотеке", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Настройки", style: .default) { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func presentAlertQuantity() {
        let alertController = UIAlertController(title: "Не достаточно контента", message: "Для работы игры необходимо как минимум 12 фото и видео в вашей библиотеке", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Понял, добавлю", style: .default) { action in
            print("надо добавить фото")
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // просто здесь для того, чтобы если что очистить хранилище рекордов времени
    @objc func deleteAllStats() {
        StorageManager.shared.deleteStats()
    }
    
}
