//
//  ViewController.swift
//  FinalProject
//
//  Created by Michael Tan on 2020-12-13.
//  Copyright © 2020 Michael Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.performSegue(withIdentifier: "showPassport", sender: self)
        }
    }

}

