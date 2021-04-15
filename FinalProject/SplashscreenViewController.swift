//
//  SplashscreenViewController.swift
//  FinalProject
//
//  Created by Michael Tan on 2020-12-13.
//  Copyright © 2020 Michael Tan. All rights reserved.
//

import UIKit

class SplashscreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0 ){
            print("next screen")
        }
        // Do any additional setup after loading the view.
    }


}
