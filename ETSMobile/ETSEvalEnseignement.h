//
//  ETSEvalEnseignement.h
//  ETSMobile
//
//  Created by Alyssa Bouchenak on 2016-05-02.
//  Copyright © 2016 ApplETS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ETSEvalEnseignement : NSManagedObject

@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * hasBeenCompleted;

@end
