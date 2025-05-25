//
//  GameViewController.swift
//  MemoMatch
//
//  Created by Роман Глухарев on 13.05.25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        presentInitialScene()
    }
    
    private func configureView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        
        // Debug configuration
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        skView.showsQuadCount = true
        
        skView.ignoresSiblingOrder = true
    }
    
    private func presentInitialScene() {
        guard let skView = skView else {
            assertionFailure("SKView not initialized")
            return
        }
        
        let loadingScene = LoadingScene(size: skView.bounds.size)
        loadingScene.scaleMode = .aspectFill
        
        skView.presentScene(loadingScene)
        
        print("Presented LoadingScene with size: \(loadingScene.size.width)x\(loadingScene.size.height)")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            // Handle orientation changes if needed
            if let scene = self.skView.scene as? LoadingScene {
                scene.size = size
            }
        })
    }
}
