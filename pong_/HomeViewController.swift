//
//  HomeViewController.swift
//  pong_
//
//  Created by Elie Bengou on 12/02/2025.
//

import UIKit
import SpriteKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func PlayButtonTapped(_ sender: UIButton) {
        transitionToGameScene(with: .standard)
    }

    @IBAction func PlayMultipleBallsModeButtonTapped(_ sender: Any) {
        transitionToGameScene(with: .twoBalls)
    }
    
    func transitionToGameScene(with mode: GameMode) {
        let gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .aspectFill
        gameScene.currentGameMode = mode
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)

        // Transition vers la vue SpriteKit
        let gameViewController = UIViewController()
        gameViewController.view = skView
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true, completion: nil)
    }
}
