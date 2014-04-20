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
					    ...
				    }
			    }];
		    }
	    }
	    [self.hueBeaconMapping setObject:hueBeacon forKey:hueBeaconKey];
    }
    ```

Just take me where the light is.

## Copyright

### Philips Hue SDK Copyright Notice
Philips releases this SDK with friendly house rules. These friendly house rules are part of a legal framework; this to protect both the developers and hue. The friendly house rules cover e.g. the naming of Philips and of hue which can only be used as a reference (a true and honest statement) and not as a an brand or identity. Also covered is that the hue SDK and API can only be used for hue and for no other application or product. Very common sense friendly rules that are common practice amongst leading brands that have released their SDK’s.


Copyright (c) 2012- 2013, Philips Electronics N.V. All rights reserved.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 
* Neither the name of Philips Electronics N.V. , nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FORA PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER ORCONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, ORPROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OFLIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDINGNEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THISSOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.