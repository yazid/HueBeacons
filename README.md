# HueBeacons

Estimote iBeacons controlling Hue lightbulbs (based on the Philips Hue iOS SDK Quick Start sample).

[Video Demo](https://www.youtube.com/watch?v=d6K9zkH9hw0)

## Usage

1. Setup your beacons in `InitRegion` of PHControlLightsViewController.m:

```
...
// Setup your iBeacons here
self.beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:19313 minor:25175 identifier:@"Blueberry Pie"];
self.beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:36081 minor:35603 identifier:@"Icy Marshmallow"];
self.beaconRegion3 = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:29580 minor:8741 identifier:@"Mint Cocktail"];
    
NSArray *hueBeaconKeys = @[@"major",@"minor",@"beaconName",@"lightIdentifier"];
    
// Setup the mapping of your Hue bulbs (light ID) here. This may take some  trial and error.
NSMutableDictionary *hueBeacon1 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion1.major,self.beaconRegion1.minor,self.beaconRegion1.identifier,@"1"] forKeys:hueBeaconKeys];
NSMutableDictionary *hueBeacon2 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion2.major,self.beaconRegion2.minor,self.beaconRegion2.identifier,@"2"] forKeys:hueBeaconKeys];
NSMutableDictionary *hueBeacon3 = [NSMutableDictionary dictionaryWithObjects:@[self.beaconRegion3.major,self.beaconRegion3.minor,self.beaconRegion3.identifier,@"3"] forKeys:hueBeaconKeys];
...
```

2. Most of the magic happens in `(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region`:

```
for (CLBeacon* beacon in beacons){
...
	for (PHLight *light in cache.lights.allValues) {
		if ([light.identifier isEqualToString:lightIdentifierForBeacon]){
			// If within 1M of the current beacon
			if(beacon.accuracy<=1.0){
				...
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
```

Just take me where the light is.
