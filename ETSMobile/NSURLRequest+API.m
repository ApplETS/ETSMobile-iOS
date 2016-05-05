//
//  NSURLRequest+API.m
//  ETSMobile
//
//  Created by Jean-Philippe Martin on 2013-11-06.
//  Copyright (c) 2013 ApplETS. All rights reserved.
//

#import "NSURLRequest+API.h"
#import "NSURL+API.h"
#import "ETSAuthenticationViewController.h"
#import "NSMutableURLRequest+BasicAuth.h"

@implementation NSURLRequest (API)

+ (NSString *)applETSUsername
{
    return (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApplETSUsername"];
}

+ (NSString *)applETSPassword
{
    return (NSString *)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"ApplETSPassword"];
}

+ (id)JSONRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    
    [request setHTTPMethod: @"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Charset"];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    
    NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    return request;
}

+ (NSMutableURLRequest *)requestWithUsernameAndPassword:(NSURL*)url
{
    NSMutableURLRequest *request = [NSURLRequest JSONRequestWithURL: url];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([ETSAuthenticationViewController passwordInKeychain]) parameters[@"motPasse"] = [ETSAuthenticationViewController passwordInKeychain];
    if ([ETSAuthenticationViewController usernameInKeychain]) parameters[@"codeAccesUniversel"] = [ETSAuthenticationViewController usernameInKeychain];
    
    NSError *error = nil;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error]];
    
    return request;
}

+ (id)requestForCourses
{
    return [self requestWithUsernameAndPassword:[NSURL URLForCourses]];
}

+ (id)requestForProfile
{
    return [self requestWithUsernameAndPassword:[NSURL URLForProfile]];
}

+ (id)requestForProgram
{
    return [self requestWithUsernameAndPassword:[NSURL URLForProgram]];
}

+ (id)requestForCalendar:(NSString *)session
{
    NSMutableURLRequest *request = [NSURLRequest JSONRequestWithURL:[NSURL URLForCalendar]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([ETSAuthenticationViewController passwordInKeychain]) parameters[@"motPasse"] = [ETSAuthenticationViewController passwordInKeychain];
    if ([ETSAuthenticationViewController usernameInKeychain]) parameters[@"codeAccesUniversel"] = [ETSAuthenticationViewController usernameInKeychain];
    parameters[@"pCoursGroupe"] = @"";
    parameters[@"pSession"] = session;
    parameters[@"pDateDebut"] = @"";
    parameters[@"pDateFin"] = @"";
    
    NSError *error = nil;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error]];
    
    return request;
}


+ (id)requestForMoodleCoursesWithToken:(NSString *)token userid:(NSString *)userid
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLForMoodle]];
    [request setHTTPMethod:@"POST"];
    NSString *parameters = [NSString stringWithFormat:@"userid=%@&wsfunction=moodle_enrol_get_users_courses&wstoken=%@&", userid, token];
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (id)requestForMoodleCourseDetailWithToken:(NSString *)token courseid:(NSString *)courseid
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLForMoodle]];
    [request setHTTPMethod:@"POST"];
    NSString *parameters = [NSString stringWithFormat:@"courseid=%@&wsfunction=core_course_get_contents&wstoken=%@", courseid, token];
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

+ (id)requestForSession
{
    return [self requestWithUsernameAndPassword:[NSURL URLForSession]];
}

+ (id)requestForEvaluationsWithCourse:(ETSCourse *)course
{
    NSMutableURLRequest *request = [NSURLRequest JSONRequestWithURL:[NSURL URLForEvaluations]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if ([ETSAuthenticationViewController passwordInKeychain]) parameters[@"motPasse"] = [ETSAuthenticationViewController passwordInKeychain];
    if ([ETSAuthenticationViewController usernameInKeychain]) parameters[@"codeAccesUniversel"] = [ETSAuthenticationViewController usernameInKeychain];
    parameters[@"pSigle"] = course.acronym;
    parameters[@"pGroupe"] = course.group;
    parameters[@"pSession"] = course.session;
    
    NSError *error = nil;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error]];
    NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
    
    return request;
}

+ (id)requestForEvalEnseignement
{
    return [self requestWithUsernameAndPassword:[NSURL URLForEvalEnseignement]];
}

+ (id)requestForDirectory
{
    NSMutableURLRequest *request = [NSURLRequest JSONRequestWithURL:[NSURL URLForDirectory]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"FiltreNom"] = @"";
    parameters[@"FiltrePrenom"] = @"";
    parameters[@"FiltreServiceCode"] = @"";
    
    NSError *error = nil;
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error]];
    return request;
}

+ (id)requestForNewsWithSources:(NSArray *)sources
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request basicAuthForRequestWithUsername:[NSURLRequest applETSUsername] password:[NSURLRequest applETSPassword]];
    request.URL = [NSURL URLForNewsWithSources:sources];

    return request;
}

+ (id)requestForCommentWithName:(NSString *)name email:(NSString *)email title:(NSString *)title rating:(NSString *)rating comment:(NSString *)comment
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request basicAuthForRequestWithUsername:[NSURLRequest applETSUsername] password:[NSURLRequest applETSPassword]];
    request.URL = [NSURL URLForComment];

    [request setHTTPMethod:@"POST"];
    NSString *parameters = [NSString stringWithFormat:@"sender_name=%@&sender_mail=%@&message=%@&subject=%@&rating=%@", name, email, comment, title, rating];
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];

    return request;
}

+ (id)requestForRadio
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request basicAuthForRequestWithUsername:[NSURLRequest applETSUsername] password:[NSURLRequest applETSPassword]];
    request.URL = [NSURL URLForRadio];
    return request;
}

+ (id)requestForUniversityCalendarStart:(NSDate *)start end:(NSDate *)end
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request basicAuthForRequestWithUsername:[NSURLRequest applETSUsername] password:[NSURLRequest applETSPassword]];
    request.URL = [NSURL URLForUniversityCalendarStart:start end:end];
    return request;
}

+ (id)requestForBandwidthWithResidence:(NSString *)residence phase:(NSString *)phase
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLForBandwidthWithResidence:residence phase:phase]];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Charset"];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    return request;
}

+ (id)requestForSponsors
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLForSponsors]];
    
    [request setHTTPMethod: @"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Accept-Charset"];
    [request setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    
   /* NSData * data = [NSURLConnection sendSynchronousRequest:request
                                          returningResponse:nil
                                                      error:nil];
    
    if (data != nil)
    {
        NSDictionary * sponsorDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:NSJSONReadingMutableContainers
                                                                             error:nil];
        if (sponsorDictionary != nil)
        {
            NSLog(@"%@", [sponsorDictionary description]);
        }
    }*/
    
    return request;
}






@end
