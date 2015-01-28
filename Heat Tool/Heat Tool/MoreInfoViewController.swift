//
//  MoreInfoViewController.swift
//  Heat Tool
//
//  Created by Michael Pulsifer on 7/19/14.
//  Copyright (c) 2014 U.S. Department of Labor. All rights reserved.
//

import UIKit

class MoreInfoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView?
    
    // start with a path of ""
    var pageURL:NSURL = NSURL.fileURLWithPath(NSBundle.mainBundle().pathForResource("", ofType: "htm")!)!
    
    required init(coder aDecoder: (NSCoder!))
    {
        super.init(coder: aDecoder)
        // Your intializations
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var viewContent = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let infoRequest = NSURLRequest(URL: self.pageURL)
        self.webView?.loadRequest(infoRequest)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPage(page:String) {
        
        // display the additional content
        let path = NSBundle.mainBundle().pathForResource(page, ofType: "htm")
        pageURL = NSURL.fileURLWithPath(path!)!
        NSLog("more info!")
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        var theTitle :String = webView.stringByEvaluatingJavaScriptFromString("document.title")!
        let requestPage:NSURLRequest = NSURLRequest(URL: pageURL)
        
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        // turn off network activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        // do stuff
        
        let requestURL = request.URL
        if navigationType == UIWebViewNavigationType.LinkClicked {
            if requestURL.scheme == "http" || requestURL.scheme == "https" {
                UIApplication.sharedApplication().openURL(requestURL)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }
    /*
    - (void)webViewDidFinishLoad:(UIWebView *)wv {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self setTitle:theTitle];
    NSURLRequest *requestPage = [NSURLRequest requestWithURL:pageURL];
    
    [self.webView loadRequest:requestPage];
    }
    */
}