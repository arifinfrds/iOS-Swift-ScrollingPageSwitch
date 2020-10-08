//
//  SinglePageViewController.swift
//  ScrollingPageSwitch
//
//  Created by Arifin Firdaus on 08/10/20.
//  Copyright © 2020 Arifin Firdaus. All rights reserved.
//

import UIKit

class SinglePageViewController: UIViewController {
    var text: String?
    @IBOutlet weak private var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = text
    }

}
