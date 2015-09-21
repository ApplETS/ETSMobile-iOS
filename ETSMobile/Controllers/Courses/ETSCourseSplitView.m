#import "ETSCourseSplitView.h"
#import "ETSCourseDetailViewController.h"

@interface ETSCourseSplitView ()

@end

@implementation ETSCourseSplitView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)splitViewController:(UISplitViewController *)splitViewController
collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController {

    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[ETSCourseDetailViewController class]]) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}
@end