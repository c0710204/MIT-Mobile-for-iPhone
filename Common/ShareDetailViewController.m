#import "ShareDetailViewController.h"
#import "MIT_MobileAppDelegate.h"
#import "UIKit+MITAdditions.h"
#import "MITMailComposeController.h"
#import "Secret.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

static NSString *kShareDetailEmail = @"Email";
static NSString *kShareDetailFacebook = @"Facebook";
static NSString *kShareDetailTwitter = @"Twitter";

@interface ShareDetailViewController () <UIActivityItemSource>
- (void)showFacebookComposeDialog;
- (void)showTwitterComposeDialog;
- (void)showMailComposeDialog;
@end

@implementation ShareDetailViewController

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}	

#pragma mark Action Sheet

// subclasses should make sure actionSheetTitle is set up before this gets called
// or call [super share:sender] at the end of this
- (void)share:(id)sender {
    if (self.shareDelegate)
    {
        UIActionSheet *sheet = nil;
        
        sheet = [[UIActionSheet alloc] initWithTitle:[self.shareDelegate actionSheetTitle]
                                            delegate:self
                                   cancelButtonTitle:nil
                              destructiveButtonTitle:nil
                                   otherButtonTitles:nil];
        
        if ([MFMailComposeViewController canSendMail])
        {
            [sheet addButtonWithTitle:kShareDetailEmail];
        }
        
        [sheet addButtonWithTitle:kShareDetailFacebook];
        
        if ([TWTweetComposeViewController canSendTweet])
        {
            [sheet addButtonWithTitle:kShareDetailTwitter];
        }
        
        [sheet addButtonWithTitle:@"Cancel"];
        sheet.cancelButtonIndex = [sheet numberOfButtons] - 1;
        
        [sheet showFromAppDelegate];
    }
}

// subclasses should make sure emailBody and emailSubject are set up before this gets called
// or call [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex] at the end of this
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kShareDetailEmail])
    {
        [self showMailComposeDialog];
        [MITMailComposeController presentMailControllerWithRecipient:nil
                                                             subject:[self.shareDelegate emailSubject]
                                                                body:[self.shareDelegate emailBody]];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kShareDetailFacebook])
    {
        [self showFacebookComposeDialog];
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:kShareDetailTwitter])
    {
        [self showTwitterComposeDialog];
    }
}

- (void)showFacebookComposeDialog
{
    BOOL newStyleSupported = [self composeForServiceType:SLServiceTypeFacebook];
    
    if (newStyleSupported == NO) {
        [self showFacebookDialog];
    }
}

- (void)showTwitterComposeDialog
{
    BOOL newStyleSupported = [self composeForServiceType:SLServiceTypeTwitter];
    
    if (newStyleSupported == NO)
    {
        TWTweetComposeViewController *tweetComposer = [[TWTweetComposeViewController alloc] init];
        [tweetComposer setInitialText:[self.shareDelegate twitterTitle]];
        
        NSURL *twURL = [NSURL URLWithString:[self.shareDelegate twitterUrl]];
        if (twURL)
        {
            [tweetComposer addURL:twURL];
        }
        
        if ([self.shareDelegate respondsToSelector:@selector(postImage)])
        {
            UIImage *image = [self.shareDelegate postImage];
            if (image)
            {
                [tweetComposer addImage:image];
            }
        }
    }
    
}

- (BOOL)composeForServiceType:(NSString*)serviceType
{
    if ([SLComposeViewController class] && [SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *composeView = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [composeView setInitialText:[self.shareDelegate twitterTitle]];
        composeView.completionHandler = ^(SLComposeViewControllerResult result) {
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Compose Canceled");
                    break;
                    
                case SLComposeViewControllerResultDone:
                    NSLog(@"Compose Finished");
                    break;
            }
            
            [self dismissModalViewControllerAnimated:YES];
        };
        
        NSURL *sharedURL = [NSURL URLWithString:[self.shareDelegate twitterUrl]];
        if (sharedURL)
        {
            [composeView addURL:sharedURL];
        }
        
        if ([self.shareDelegate respondsToSelector:@selector(postImage)])
        {
            UIImage *image = [self.shareDelegate postImage];
            if (image)
            {
                [composeView addImage:image];
            }
        }
        
        [self presentViewController:composeView
                           animated:YES
                         completion:nil];
        return YES;
    }
    
    return NO;
}

- (void)showMailComposeDialog
{
    if ([SLComposeViewController class] == nil)
    {
        
    }
    else
    {
        
    }
}

#pragma mark -
#pragma mark Facebook delegation
- (void)showFacebookDialog
{

}

- (void)postItemToFacebook {

}

#pragma mark -

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
         
#pragma mark - UIActivityItemSource
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    id result = nil;
    
    if (self.shareDelegate == nil)
    {
        return nil;
    }
    else if ([activityType isEqualToString:UIActivityTypeMail])
    {
        result = [self.shareDelegate emailBody];
    }
    else if ([activityType isEqualToString:UIActivityTypePostToFacebook])
    {
        result = [NSString stringWithFormat:@"(MIT Mobile test) Check out this link from the MIT News office!\n'%@'\n\t%@", [self.shareDelegate twitterTitle],[self.shareDelegate twitterUrl]];
    }
    else if ([activityType isEqualToString:UIActivityTypePostToTwitter])
    {
        result = [NSString stringWithFormat:@"(MIT Mobile test) '%@': %@", [self.shareDelegate twitterTitle],[self.shareDelegate twitterUrl]];
    }
    
    return result;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [NSString stringWithFormat:@"%@: %@", [self.shareDelegate twitterTitle],[self.shareDelegate twitterUrl]];
}

@end
