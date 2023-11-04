//
//  Dialog.swift
//  Practica iOS
//
//  Created by Etwan on 03/11/23.
//

import UIKit
import Popover

class Dialog: UIView {
    
    @IBOutlet weak var estado: UILabel!
    @IBOutlet weak var pais: UILabel!
    @IBOutlet weak var coordenadas: UILabel!
    @IBOutlet weak var latitud: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func commonInit() {
        let viewFromXib = Bundle.main.loadNibNamed("Dialog", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        addSubview(viewFromXib)
    }
}
