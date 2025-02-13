//
//  GameScene.swift
//  pong_
//
//  Created by Elie Bengou on 12/02/2025.
//

import SpriteKit
import GameplayKit
import AVFoundation
import HomeKit

protocol GameSceneDelegate: AnyObject {
    func didRequestReturnToHome()
}

class GameScene: SKScene, SKPhysicsContactDelegate, HMHomeManagerDelegate {
    weak var gameSceneDelegate: GameSceneDelegate?
    
    var currentGameMode: GameMode = .standard
    var balls: [SKShapeNode] = []
    var topPaddle: SKShapeNode?
    var bottomPaddle: SKShapeNode?
    var topBallDetector: SKShapeNode?
    var bottomBallDetector: SKShapeNode?
    var topScore: SKLabelNode?
    var bottomScore: SKLabelNode?

    let ballRadius: CGFloat = 10
    let paddleSize = CGSize(width: 100, height: 10)
    let paddleEdgeOffset: CGFloat = 60
    let wallWidth: CGFloat = 10

    var topPlayerScore = 0
    var bottomPlayerScore = 0
    
    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
    
    var homeManager: HMHomeManager!
    var joystickXPlayer1: HMCharacteristic?
    var joystickXPlayer2: HMCharacteristic?

    override func didMove(to view: SKView) {
        startGame()
        setupHomeKit()
    }

    func startGame() {
        self.removeAllChildren()
        setUpPhysicsWorld()
        createBalls()
        createWalls()
        createPassedBallDetectors()
        createPaddles()
        createScore()
        resetBalls()
    }

    func setUpPhysicsWorld() {
        self.physicsWorld.gravity = .zero
        self.physicsWorld.contactDelegate = self
    }

    func createBalls() {
        if currentGameMode == .standard {
            createBall()
        } else if currentGameMode == .twoBalls {
            createBall()
            createBall()
        }
    }

    func createBall() {
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.friction = 0
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.angularDamping = 0
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.contactTestBitMask = 2
        ball.physicsBody?.collisionBitMask = 3
        ball.strokeColor = .white
        ball.fillColor = .white

        addChild(ball)
        balls.append(ball)
    }

    func resetBalls() {
        for ball in balls {
            ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
            ball.physicsBody?.velocity = .zero
            let dx = CGFloat.random(in: 5...8) * (Bool.random() ? 1 : -1)
            let dy = CGFloat.random(in: 5...8) * (Bool.random() ? 1 : -1)
            ball.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
        }
    }

    func createWalls() {
        createVerticalWall(x: wallWidth / 2)
        createVerticalWall(x: size.width - wallWidth / 2)
    }

    func createVerticalWall(x: CGFloat) {
        let wall = SKShapeNode(rectOf: CGSize(width: wallWidth, height: size.height))
        wall.position = CGPoint(x: x, y: size.height / 2)
        wall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: wallWidth, height: size.height))
        wall.physicsBody?.isDynamic = false
        wall.strokeColor = .clear
        wall.fillColor = .clear
        addChild(wall)
    }

    func createPassedBallDetectors() {
        bottomBallDetector = createDetector(y: 5)
        topBallDetector = createDetector(y: size.height - 5)
    }

    func createDetector(y: CGFloat) -> SKShapeNode {
        let detector = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        detector.position = CGPoint(x: size.width / 2, y: y)
        detector.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 0))
        detector.physicsBody?.isDynamic = false
        detector.physicsBody?.categoryBitMask = 2
        addChild(detector)
        return detector
    }

    func createPaddles() {
        bottomPaddle = createPaddle(y: paddleEdgeOffset)
        topPaddle = createPaddle(y: size.height - paddleEdgeOffset)
    }

    func createPaddle(y: CGFloat) -> SKShapeNode {
        let paddle = SKShapeNode(rectOf: paddleSize)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddleSize)
        paddle.physicsBody?.isDynamic = false
        paddle.position = CGPoint(x: size.width / 2, y: y)
        paddle.strokeColor = .white
        paddle.fillColor = .white
        addChild(paddle)
        return paddle
    }

    func createScore() {
        bottomScore = createScoreLabel(y: size.height / 2 - 30)
        topScore = createScoreLabel(y: size.height / 2 + 30)
    }

    func createScoreLabel(y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(text: "0")
        label.fontSize = 24
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: y)
        addChild(label)
        return label
    }

    override func update(_ currentTime: TimeInterval) {
        updatePaddlePositionFromHomeKit()
        for ball in balls {
            if ball.position.y < 0 {
                topPlayerScore += 1
                topScore?.text = "\(topPlayerScore)"
                checkForWinCondition()
                resetBalls()
            } else if ball.position.y > size.height {
                bottomPlayerScore += 1
                bottomScore?.text = "\(bottomPlayerScore)"
                checkForWinCondition()
                resetBalls()
            }
        }
    }

    func setupHomeKit() {
        DispatchQueue.main.async {
            self.homeManager = HMHomeManager()
            self.homeManager.delegate = self
        }
    }

    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if let home = manager.primaryHome {
            for accessory in home.accessories {
                print("📡 Accessory found: \(accessory.name)")

                for service in accessory.services {
                    for characteristic in service.characteristics {
                        if characteristic.properties.contains(HMCharacteristicPropertyReadable) {
                            if accessory.name == "player-1" {
                                joystickXPlayer1 = characteristic
                                print("✅ Joystick X Player 1 trouvé et initialisé")
                            } else if accessory.name == "player-2" {
                                joystickXPlayer2 = characteristic
                                print("✅ Joystick X Player 2 trouvé et initialisé")
                            }
                        }
                    }
                }
            }
        } else {
            print("❌ Aucun domicile HomeKit configuré")
        }
    }

    func updatePaddlePositionFromHomeKit() {
        updatePaddlePosition(for: joystickXPlayer1, paddle: bottomPaddle)
        updatePaddlePosition(for: joystickXPlayer2, paddle: topPaddle)
    }

    func updatePaddlePosition(for joystickX: HMCharacteristic?, paddle: SKShapeNode?) {
        guard let joystickX = joystickX, let paddle = paddle else {
            print("❌ Joystick non initialisé")
            return
        }
        
        joystickX.enableNotification(true) { error in
            if let error = error {
                print("❌ Erreur d’activation des notifications: \(error.localizedDescription)")
            } else {
                print("✅ Notifications activées pour Joystick X")
            }
        }
        
        if joystickX.properties.contains(HMCharacteristicPropertyReadable) {
            joystickX.readValue { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Erreur HomeKit: \(error.localizedDescription)")
                    return
                }
                DispatchQueue.main.async {
                    if let xValue = joystickX.value as? Int {
                        print("🎮 Joystick X Value: \(xValue)")
                        let screenWidth = UIScreen.main.bounds.width
                            let paddleWidth = paddle.frame.width
                        let newX = CGFloat(CGFloat(xValue) + paddle.position.x)
                            let minX = paddleWidth / 2
                            let maxX = screenWidth - paddleWidth / 2
                        paddle.position = CGPoint(x: min(max(newX, minX), maxX), y: paddle.position.y)
                    } else {
                        print("⚠️ Valeur du joystick incorrecte: \(joystickX.value ?? "nil")")
                    }
                }
            }
        } else {
            print("❌ La caractéristique du joystick ne supporte pas la lecture")
        }
    }

    func checkForWinCondition() {
        let winningScore = 10
        if topPlayerScore >= winningScore {
            showEndGameMessage(winner: "Top Player")
        } else if bottomPlayerScore >= winningScore {
            showEndGameMessage(winner: "Bottom Player")
        }
    }
    
    func hideAllGameElements() {
        for ball in balls {
            ball.isHidden = true
        }
        topPaddle?.isHidden = true
        topScore?.isHidden = true
        bottomPaddle?.isHidden = true
        bottomScore?.isHidden = true
    }
    
    func showEndGameMessage(winner: String) {
        hideAllGameElements()

        let message = SKLabelNode(text: "\(winner) Wins!")
        message.fontSize = 32
        message.fontColor = .yellow
        message.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        addChild(message)

        let replayButton = SKLabelNode(text: "Retry")
        replayButton.name = "replayButton"
        replayButton.fontSize = 24
        replayButton.fontColor = .white
        replayButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 10)
        addChild(replayButton)

        let homeButton = SKLabelNode(text: "Home")
        homeButton.name = "homeButton"
        homeButton.fontSize = 24
        homeButton.fontColor = .white
        homeButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        addChild(homeButton)

        self.isPaused = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "replayButton" {
            resetGame()
        } else if touchedNode.name == "homeButton" {
            goToHomePage()
        }
    }

    func resetGame() {
        topPlayerScore = 0
        bottomPlayerScore = 0
        self.isPaused = false
        startGame()
    }
    
    func goToHomePage() {
        gameSceneDelegate?.didRequestReturnToHome()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let bottomPaddle = bottomPaddle, location.y < size.height / 2 {
            bottomPaddle.position.x = location.x
        } else if let topPaddle = topPaddle, location.y > size.height / 2 {
            topPaddle.position.x = location.x
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        playBouncingSound()
    }
    
    func playBouncingSound() {
        if let soundURL = Bundle.main.url(forResource: "bouncing", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer.play()
            } catch {
                print("Erreur lors de la lecture du fichier audio: \(error.localizedDescription)")
            }
        }
    }
}
