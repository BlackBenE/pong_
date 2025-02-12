//
//  HomeViewController.swift
//  pong_
//
//  Created by Elie Bengou on 12/02/2025.
//

import UIKit
import SpriteKit

class HomeViewController: UIViewController, GameSceneDelegate {
    
    func didRequestReturnToHome() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        gameScene.gameSceneDelegate = self
        gameScene.currentGameMode = mode
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)
        let gameViewController = UIViewController()
        gameViewController.view = skView
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true, completion: nil)
    }
}
