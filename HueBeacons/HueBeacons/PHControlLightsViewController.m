/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHControlLightsViewController.h"
#import "PHAppDelegate.h"

#import <HueSDK_iOS/HueSDK.h>
#define MAX_HUE 65535
#define ESTIMOTE_UUID @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"

@interface PHControlLightsViewController()

@property (nonatomic,weak) IBOutlet UILabel *bridgeMacLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeIpLabel;
@property (nonatomic,weak) IBOutlet UILabel *bridgeLastHeartbeatLabel;
@property (nonatomic,weak) IBOutlet UILabel *beaconsLabel;


@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) CLBeaconRegion* beaconRegion1;
@property (nonatomic, strong) CLBeaconRegion* beaconRegion2;
@property (nonatomic, strong) CLBeaconRegion* beaconRegion3;
@property (nonatomic, strong) NSMutableDictionary* hueBeaconMapping;

@end


@implementation PHControlLightsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    // Register for the local heartbeat notifications
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Find bridge" style:UIBarButtonItemStylePlain target:self action:@selector(findNewBridgeButtonAction)];
    
    self.navigationItem.title = @"HueBeacons";
    
    [self noLocalConnection];

    self.hueBeaconMapping = [NSMutableDictionary dictionary];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self initRegion];
    [self updateBeaconLabel];
}

- (UIRectEdge)edgesForExtendedLayout {
    return UIRectEdgeLeft | UIRectEdgeBottom | UIRectEdgeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initRegion
{
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:ESTIMOTE_UUID];
    
    // Setup your iBeacons here
    self.beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:19313 minor:25175 identifier:@"Blueberry Pie"];
    self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:36081 minor:35603 identifier:@"Icy Marshmallow"];
    self.beaconRegion3 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:29580 minor:8741 identifier:@"Mint Cocktail"];
    
    NSArray *hueBeaconKeys = @[@"major",@"minor",@"beaconName",@"lightIdentifier"];
    
    // Setup the mapping of your Hue bulbs (light ID) here. This may take some  trial and error.
    NSMutableDictionary *hueBeacon1 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion1.major,self.beaconRegion1.minor,self.beaconRegion1.identifier,@"1"] forKeys:hueBeaconKeys];
    NSMutableDictionary *hueBeacon2 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion2.major,self.beaconRegion2.minor,self.beaconRegion2.identifier,@"2"] forKeys:hueBeaconKeys];
    NSMutableDictionary *hueBeacon3 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion3.major,self.beaconRegion3.minor,self.beaconRegion3.identifier,@"3"] forKeys:hueBeaconKeys];
    
    [self.hueBeaconMapping setObject:hueBeacon1 forKey:[NSString stringWithFormat:@"%@/%@", self.beaconRegion1.major, self.beaconRegion1.minor]];
    [self.hueBeaconMapping setObject:hueBeacon2 forKey:[NSString stringWithFormat:@"%@/%@", self.beaconRegion2.major, self.beaconRegion2.minor]];
    [self.hueBeaconMapping setObject:hueBeacon3 forKey:[NSString stringWithFormat:@"%@/%@", self.beaconRegion3.major, self.beaconRegion3.minor]];
     
    self.beaconRegion1.notifyOnEntry = YES;
    self.beaconRegion1.notifyOnExit = YES;
    self.beaconRegion1.notifyEntryStateOnDisplay = YES;
    self.beaconRegion2.notifyOnEntry = YES;
    self.beaconRegion2.notifyOnExit = YES;
    self.beaconRegion2.notifyEntryStateOnDisplay = YES;
    self.beaconRegion3.notifyOnEntry = YES;
    self.beaconRegion3.notifyOnExit = YES;
    self.beaconRegion3.notifyEntryStateOnDisplay = YES;
    
    [self.locationManager startMonitoringForRegion:self.beaconRegion1];
    [self.locationManager startMonitoringForRegion:self.beaconRegion2];
    [self.locationManager startMonitoringForRegion:self.beaconRegion3];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:region];
    NSLog(@"didStartMonitoringForRegion: %@",region.identifier);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on ranging: Location services not authorised.");
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:region];
     
    NSLog(@"didEnterRegion: %@", region.identifier);
}

- (void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            NSLog(@"Inside %@ region!", region.identifier);
        case CLRegionStateOutside:
            NSLog(@"Left %@ region!", region.identifier);
        case CLRegionStateUnknown:
        default:
            NSLog(@"Region %@ state unknown.", region.identifier);
    }
}

- (void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    NSString *hueBeaconKey = [NSString stringWithFormat:@"%@/%@", region.major, region.minor];
    
    if ([beacons count] > 0) {
        
        for (CLBeacon* beacon in beacons){
            NSMutableDictionary *hueBeacon = [self.hueBeaconMapping objectForKey:hueBeaconKey];
            PHLightState *lightState = [[PHLightState alloc] init];
            NSString *lightIdentifierForBeacon = [hueBeacon objectForKey:@"lightIdentifier"];
            [hueBeacon setObject:beacon forKey:@"beacon"];
            
            for (PHLight *light in cache.lights.allValues) {
                if ([light.identifier isEqualToString:lightIdentifierForBeacon]){
                    // If within 1M of the current beacon
                    if(beacon.accuracy<=1.0){
                        // This line will also randomize the bulb's color
                        //[lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
                        [lightState setOnBool:YES];
                    } else {
                        [lightState setOnBool:NO];
                    }
                    
                    [bridgeSendAPI updateLightStateForId:lightIdentifierForBeacon withLighState:lightState completionHandler:^(NSArray *errors) {
                        if (errors != nil) {
                            NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                            
                            NSLog(@"Response: %@",message);
                        }
                    }];
                    
                }
            }
            
            [self.hueBeaconMapping setObject:hueBeacon forKey:hueBeaconKey];
        }
    }
    
    [self updateBeaconLabel];
    
    /*
    if ([region.identifier isEqualToString:@"Blueberry Pie"]){
        lightIdentifier = @"1";
        if ([beacons count] > 0) {
             for (CLBeacon* beacon in beacons){
                 for (PHLight *light in cache.lights.allValues) {
                     PHLightState *currentLightState = [[PHLightState alloc] init];
                     if ([light.identifier isEqualToString:lightIdentifier]){
                         if(beacon.proximity==CLProximityNear){
                             [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
                             [lightState setOnBool:YES];
                         } else {
                             [lightState setOnBool:NO];
                         }
                     }
                 }
             }
        }
    }
    */
}

- (void) locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Monitoring failed: %@", [error localizedDescription]);
}

- (void) locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Ranging failed: %@", [error localizedDescription]);
}

-(void)updateBeaconLabel{
    NSString *beaconsLabelString = @"";
    
    for(NSString *key in [self.hueBeaconMapping allKeys]){
        NSDictionary *hueBeacon = [self.hueBeaconMapping objectForKey:key];

        NSString *accuracyString = @"";
        CLBeacon *beacon = [hueBeacon objectForKey:@"beacon"];
        if(beacon)
        {
            accuracyString = [NSString stringWithFormat:@"%fM",beacon.accuracy];
        } else {
            accuracyString = @"Undetected";
        }
        
        NSString *currentBeaconString = [NSString stringWithFormat:@"%@\n(Bulb %@ • Proximity: %@)\n\n",[hueBeacon objectForKey:@"beaconName"],[hueBeacon objectForKey:@"lightIdentifier"],accuracyString];
        beaconsLabelString = [beaconsLabelString stringByAppendingString:currentBeaconString];
    }
    
    self.beaconsLabel.text = beaconsLabelString;
}

- (void)localConnection{
    
    [self loadConnectedBridgeValues];
    
}

- (void)noLocalConnection{
    self.bridgeLastHeartbeatLabel.text = @"Not connected";
    [self.bridgeLastHeartbeatLabel setEnabled:NO];
    self.bridgeIpLabel.text = @"Not connected";
    [self.bridgeIpLabel setEnabled:NO];
    self.bridgeMacLabel.text = @"Not connected";
    [self.bridgeMacLabel setEnabled:NO];
    
    //[self.randomLightsButton setEnabled:NO];
}

- (void)loadConnectedBridgeValues{
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    // Check if we have connected to a bridge before
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil){
        
        // Set the ip address of the bridge
        self.bridgeIpLabel.text = cache.bridgeConfiguration.ipaddress;
        
        // Set the mac adress of the bridge
        self.bridgeMacLabel.text = cache.bridgeConfiguration.mac;
        
        // Check if we are connected to the bridge right now
        if (UIAppDelegate.phHueSDK.localConnected) {
            
            // Show current time as last successful heartbeat time when we are connected to a bridge
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterNoStyle];
            [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
            
            self.bridgeLastHeartbeatLabel.text = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
            
            //[self.randomLightsButton setEnabled:YES];
        } else {
            self.bridgeLastHeartbeatLabel.text = @"Waiting...";
            //[self.randomLightsButton setEnabled:NO];
        }
    }
}

- (IBAction)selectOtherBridge:(id)sender{
    [UIAppDelegate searchForBridgeLocal];
}

/*
- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}
*/
 
- (void)findNewBridgeButtonAction{
    [UIAppDelegate searchForBridgeLocal];
}

@end
