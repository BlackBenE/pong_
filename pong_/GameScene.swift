//
//  GameScene.swift
//  pong_
//
//  Created by Elie Bengou on 12/02/2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var ball: SKShapeNode?
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

    override func didMove(to view: SKView) {
        startGame()
    }

    func startGame() {
        // Réinitialisation de la scène
        self.removeAllChildren()
        setUpPhysicsWorld()
        createBall()
        createWalls()
        createPassedBallDetectors()
        createPaddles()
        createScore()
        resetBall()
    }

    func setUpPhysicsWorld() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
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
        self.ball = ball
    }

    func resetBall() {
        ball?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        ball?.physicsBody?.velocity = .zero
        let dx = Int.random(in: -20...20)
        let dy = Int.random(in: -20...20)
        ball?.physicsBody?.applyImpulse(CGVector(dx: dx, dy: dy))
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
        bottomBallDetector = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        bottomBallDetector?.position = CGPoint(x: size.width / 2, y: -10)
        bottomBallDetector?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        bottomBallDetector?.physicsBody?.isDynamic = false
        bottomBallDetector?.physicsBody?.categoryBitMask = 2
        addChild(bottomBallDetector!)

        topBallDetector = SKShapeNode(rectOf: CGSize(width: size.width, height: 10))
        topBallDetector?.position = CGPoint(x: size.width / 2, y: size.height + 10)
        topBallDetector?.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width, height: 10))
        topBallDetector?.physicsBody?.isDynamic = false
        topBallDetector?.physicsBody?.categoryBitMask = 2
        addChild(topBallDetector!)
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
        bottomScore = SKLabelNode(text: "0")
        bottomScore?.fontSize = 24
        bottomScore?.fontColor = .white
        bottomScore?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 30)
        addChild(bottomScore!)

        topScore = SKLabelNode(text: "0")
        topScore?.fontSize = 24
        topScore?.fontColor = .white
        topScore?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 30)
        addChild(topScore!)
    }

    override func update(_ currentTime: TimeInterval) {
        // Vérifiez si la balle touche un détecteur
        if let ball = ball {
            if ball.position.y < 0 {
                topPlayerScore += 1
                topScore?.text = "\(topPlayerScore)"
                resetBall()
            } else if ball.position.y > size.height {
                bottomPlayerScore += 1
                bottomScore?.text = "\(bottomPlayerScore)"
                resetBall()
            }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        // Gérer les collisions (si nécessaire pour des effets)
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
}

