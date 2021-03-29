//
//  WebView.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 3/25/21.
//
import UIKit
import WebKit

class WebPageViewController: UIViewController,WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    var pageUrl="https://docs.google.com/document/d/1vv5bLGjSRPM_qMjMzX7SCWdbuMkG-miZvM1-A-sSBSc/edit?usp=sharing"
    
    override func viewDidLoad() {
         
        pageUrl="https://tinyurl.com/FAQ-aerosols"
        pageUrl="https://sites.google.com/view/teammdsco2senseitake1/home"
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        let url = URL(string: pageUrl)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true

    }


}
