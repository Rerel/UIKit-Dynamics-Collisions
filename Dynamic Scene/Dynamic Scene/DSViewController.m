//
//  DSViewController.m
//  Dynamic Scene
//  Using UIKit Dynamics, CoreGraphics & Gesture recognizersa
//
//  Created by Aurélien Lemesle on 27/03/14.
//  Copyright (c) 2014 Aurélien Lemesle. All rights reserved.
//

#import "DSViewController.h"

@interface DSViewController () <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIView *ballView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIPushBehavior *pusher;
@property (nonatomic, strong) UICollisionBehavior *collider;
@property (nonatomic, strong) UIDynamicItemBehavior *ballDynamicProperties;

@end

@implementation DSViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Ball geometry & color
    CGRect ballFrame = CGRectMake(100.0, 100.0, 100.0, 100.0);
    self.ballView = [[UIView alloc] initWithFrame:ballFrame];
    self.ballView.layer.cornerRadius = 50.0;
    self.ballView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.ballView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveBall:)];
    [self.view addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stopBall:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initBehaviors];
}

#pragma mark - Behaviors

- (void)initBehaviors {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // Collisions with screen bounds
    self.collider = [[UICollisionBehavior alloc] initWithItems:@[self.ballView]];
    self.collider.collisionDelegate = self;
    self.collider.collisionMode = UICollisionBehaviorModeEverything;
    self.collider.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collider];
    
    // Set ball dynamic properties for collisions
    self.ballDynamicProperties = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.ballDynamicProperties.elasticity = 1.0;
    self.ballDynamicProperties.friction = 0.0;
    self.ballDynamicProperties.allowsRotation = NO;
    self.ballDynamicProperties.resistance = 0.0;
    [self.animator addBehavior:self.ballDynamicProperties];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier {
    // Change ball color after collision on screen bounds
    CGFloat hue = ( arc4random() % 256 / 256.0 );
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    self.ballView.backgroundColor = color;
}

#pragma mark - Gestures management

- (void)moveBall:(UIPanGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if(self.pusher) {
            [self.animator removeBehavior:self.pusher];
        }
        self.pusher = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
        [self.animator addBehavior:self.pusher];
    }
    
    CGPoint touchPosition = [gesture translationInView:self.view];
    self.pusher.pushDirection = CGVectorMake(touchPosition.x / 5.f, touchPosition.y / 5.f);
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.animator removeBehavior:self.pusher];
        self.pusher = nil;
    }
}

- (void)stopBall:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.animator removeAllBehaviors];
        [self initBehaviors];
    }
}

#pragma mark - Orientation

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
