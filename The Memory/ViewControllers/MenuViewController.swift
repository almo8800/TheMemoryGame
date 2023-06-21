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
    
    var timeArray: [GameTime] = []
    var levelHigh: HardLevel = HardLevel.four
    
    var deleteButton = UIButton()
    
    var firstTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Label 1"
        return label
    }()
    
    var secondTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Label 2"
        return label
    }()
    
    var thirdsTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Label 3"
        return label
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.setTitle("START GAME", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = .systemGray
        button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: HardLevel.allValues())
        view.selectedSegmentIndex = 0
        view.addTarget(self, action: #selector(levelChanged), for: .valueChanged)
        return view
    }()
    
    
    
    @objc func startButtonTapped() {
        let sceneDelegate = SceneDelegate.shared
        sceneDelegate?.window?.rootViewController = GameViewController()
        
    }
    
    @objc func levelChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            levelHigh = HardLevel.four
        case 1:
            levelHigh = HardLevel.five
        default:
            print("level high default")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        addLabels()
        
        NSLayoutConstraint.activate([
        
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            segmentedControl.widthAnchor.constraint(equalToConstant: 100),
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            segmentedControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            
            startButton.topAnchor.constraint(equalTo: segmentedControl.topAnchor, constant: 40),
            startButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.widthAnchor.constraint(equalToConstant: 200)
        
        ])
        
        fetchStat()
        sortStat()
        
        


    }
    
    private func addLabels(){
//        view.addSubview(firstTimeLabel)
//        view.addSubview(secondTimeLabel)
//        view.addSubview(thirdsTimeLabel)
        
        let labelsStackView = UIStackView(arrangedSubviews: [firstTimeLabel, secondTimeLabel, thirdsTimeLabel, deleteButton])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 8
        labelsStackView.alignment = .center
        
        view.addSubview(labelsStackView)
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelsStackView.topAnchor.constraint(equalTo: startButton.bottomAnchor, constant: 50).isActive = true
        
        deleteButton.backgroundColor = .blue
        deleteButton.setTitle("DELETE", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAllStats), for: .touchUpInside)
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
        
        
        self.firstTimeLabel.text = sortedTime[0].time
        self.secondTimeLabel.text = sortedTime[1].time
        self.thirdsTimeLabel.text = sortedTime[2].time
        
    }
    
    @objc func deleteAllStats() {
        StorageManager.shared.cleanData2()
    }

    deinit {
        print("MENU DEINIT")
    }
    
}
