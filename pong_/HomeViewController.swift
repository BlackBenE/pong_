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
        
        let gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .aspectFill

        // Configure la vue SpriteKit
        let skView = SKView(frame: view.bounds)
        skView.presentScene(gameScene)

        // Transition vers la vue SpriteKit
        let gameViewController = UIViewController()
        gameViewController.view = skView
        gameViewController.modalPresentationStyle = .fullScreen
        present(gameViewController, animated: true, completion: nil)
    
    }

}
