//
//  GameScene.swift
//  CHI
//
//  Created by XXXXXX on 27/02/16.
//  Copyright (c) 2017 XXXXXX. All rights reserved.
//

import SpriteKit
import Photos

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //images data
    var images: NSMutableArray!
    var totalImageCountNeeded:Int!
    
    //gameplay data
    let world = SKNode()
    let maxForce:CGFloat = 20000
    let maxNumber = 10
    //let thingMass:CGFloat = 1
    var thingArray:[SKSpriteNode] = [SKSpriteNode]()
    
    //flicking mechanic
    var touchPoint:CGPoint = CGPoint()
    var touching:Bool = false
    var thingMoved:String = String()
    
    //selecting a picture
    var slc:SKSpriteNode = SKSpriteNode()
    var bg:SKSpriteNode = SKSpriteNode()
    
    override func didMove(to view: SKView)
    {
        //we start by loading the pictures to an array
        fetchPhotos()
        
        //background color and adding a world node to the scene to manage location
        self.backgroundColor = UIColor.white
        self.addChild(world)
        
        //adding a new node
        slc = SKSpriteNode(color: UIColor.red, size: CGSize(width: self.size.width * 2, height: 100))
        slc.anchorPoint = CGPoint(x: 0, y: 0)
        slc.position = CGPoint(x: 0, y: self.size.height - self.size.height/6)
        slc.zPosition = 1
        world.addChild(slc)
        
        bg = SKSpriteNode(color: UIColor.white, size: CGSize(width: 500, height: 500))
        bg.anchorPoint = CGPoint(x: 0.5,y: 0.5)
        bg.position = CGPoint(x: self.size.width/2, y: self.size.width)
        world.addChild(bg)
        
        for i in 0 ..< images.count
        {
            let texture = SKTexture(image: images[i] as! UIImage)
            let thing = SKSpriteNode(texture: texture, size: CGSize(width: 40, height: 40))
            let equis = randomBetweenNumbers(0, secondNum: self.size.width)
            let yGriega = randomBetweenNumbers(0, secondNum: self.size.height - self.size.height/4)
            thing.position = CGPoint(x: equis, y: yGriega)
            thing.physicsBody = SKPhysicsBody(rectangleOf: thing.size)
            thing.physicsBody?.affectedByGravity = true
            thing.physicsBody?.usesPreciseCollisionDetection = true
            //thing.physicsBody?.mass = thingMass
            thing.name = "thing"+String(i)
            thingArray.append(thing)
            world.addChild(thing)
        }
        
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
    }
    
    func randomBetweenNumbers(_ firstNum: CGFloat, secondNum: CGFloat) -> CGFloat
    {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch: AnyObject in touches
        {
            let location = touch.location(in: self)
            
            for element in thingArray
            {
                if element.frame.contains(location)
                {
                    touchPoint = location
                    touching = true
                    thingMoved = element.name!
                }
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch:AnyObject in touches
        {
            let location = touch.location(in: self)
            touchPoint = location
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touching = false
        thingMoved = ""
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        touching = false
        thingMoved = ""
    }
    
    
    override func update(_ currentTime: TimeInterval)
    {
        checkContact()
    }
    
    func checkContact()
    {
        for element in thingArray
        {
            if element.name == thingMoved
            {
                let dt:CGFloat = 1.0/60.0
                let distance = CGVector(dx: touchPoint.x-element.position.x, dy: touchPoint.y-element.position.y)
                let velocity = CGVector(dx: distance.dx/dt, dy: distance.dy/dt)
                element.physicsBody!.velocity = velocity
            }
            
            //element.position = CGPoint(x: touchPoint.x, y: touchPoint.y)
            
            if element.position.y > self.size.height - self.size.height/6
            {
                slc.zPosition = -2
                let bgd = fetchSelectedPhoto(thingArray.index(of: element)!)
                bg.texture = SKTexture(image: bgd)
                bg.zPosition = -1
            }
            
        }
        
    }
    
    func fetchPhotos()
    {
        images = NSMutableArray()
        totalImageCountNeeded = 10
        self.fetchPhotoAtIndexFromEnd(0)
        
    }
    
    func fetchPhotoAtIndexFromEnd(_ index:Int)
    {
        
        let manager = PHImageManager.default()
        
        //this returns just the thumbnail
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        //sort images by creation date
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        if let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        {
            if fetchResult.count > 0
            {
                manager.requestImage(for: fetchResult.object(at: fetchResult.count - 1 - index) as! PHAsset, targetSize: view!.frame.size, contentMode: PHImageContentMode.aspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    //                manager.requestImageForAsset(fetchResult.objectAtIndex(fetchResult.count - 1 - index) as! PHAsset, targetSize: targetSize, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
                    
                    self.images.add(image!)
                    
                    if index + 1 < fetchResult.count && self.images.count < self.totalImageCountNeeded {
                        self.fetchPhotoAtIndexFromEnd(index + 1)
                    } else {
                        // Else you have completed creating your array
                        //print("Completed array: \(self.images)")
                    }
                })
                
            }
        }
        
    }
    
    func fetchSelectedPhoto(_ index: Int) -> UIImage
    {
        return(images[index]) as! UIImage
    }
    
}


