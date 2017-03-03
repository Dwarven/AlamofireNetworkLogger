//
//  ViewController.swift
//  AlamofireNetworkLogger
//
//  Created by Dwarven on 2017/3/3.
//  Copyright © 2017 Dwarven. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Alamofire.request(
            "https://httpbin.org/post",
            method: .post,
            parameters:["key":"value"],
            encoding: JSONEncoding.default
            ).responseJSON{ response in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

