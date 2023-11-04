//
//  ViewController.swift
//  Practica iOS
//
//  Created by Etwan on 30/10/23.
//

import UIKit
import MapKit
import Popover

class CellClass: UITableViewCell{}

class ViewController: UIViewController {
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var btnPaises: UIButton!
    @IBOutlet weak var btnEstados: UIButton!
    @IBOutlet weak var mapa: MKMapView!
    var selectedButton = UIButton()
    var selectedList = ""
    var viewModelP = ViewModelPaises()
    var viewModelE = ViewModelEstados()
    
    private var dataSource: [String] = []
    
    let transparentView = UIView()
    let PopOverView = UIView()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
        bind()
        
        mapa.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
    }
    
    private func configureView(){
        activity.isHidden = false
        activity.startAnimating()
        viewModelP.getData()
    }
    
    private func bind(){
        viewModelP.refreshData = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.activity.stopAnimating()
                self?.activity.isHidden = true
            }
        }
    }
    
    func addTransparentView(frames: CGRect){
        let window = UIApplication.shared.keyWindow
        transparentView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:.curveEaseOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count*45))
        }, completion: nil)
    }
    
    @objc func removeTransparentView(){
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:.curveEaseOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    func addPopOverView(frames: CGRect){
        let window = UIApplication.shared.keyWindow
        self.PopOverView.frame = window?.frame ?? self.view.frame
        self.view.addSubview(PopOverView)
        
        self.PopOverView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removePopOverView))
        self.PopOverView.addGestureRecognizer(tapgesture)
        self.PopOverView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:.curveEaseOut, animations: {
            self.PopOverView.alpha = 0.5
        }, completion: nil)
    }
    
    @objc func removePopOverView(){
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options:.curveEaseOut, animations: {
            self.PopOverView.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func getPaises(_ sender: Any) {
        self.dataSource = viewModelP.dataSource
        self.tableView.reloadData()
        btnEstados.titleLabel?.text = "Estados"
        selectedList = "pais"
        selectedButton = btnPaises
        addTransparentView(frames: btnPaises.frame)
    }
    
    @IBAction func getEstados(_ sender: Any) {
        self.dataSource = viewModelE.dataSource
        self.tableView.reloadData()
        selectedList = "estados"
        selectedButton = btnEstados
        addTransparentView(frames: btnEstados.frame)
    }
    
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        removeTransparentView()
        if selectedList == "pais" {
            btnPaises.titleLabel?.text = dataSource[indexPath.row]
            viewModelE.getData(idEstado: "\(indexPath.row+1)")
        }else{
            btnEstados.titleLabel?.text = dataSource[indexPath.row]
            print(viewModelE.items[indexPath.row].coordenadasEstado)
            
            let array = viewModelE.items[indexPath.row].coordenadasEstado.components(separatedBy: ",")
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: Double(array[0])!, longitude: Double("\(array[1])".trimmingCharacters(in: .whitespaces))!)
            annotation.title = viewModelE.items[indexPath.row].nombreEstado
            for item in viewModelP.items {
                if item.idPais == viewModelE.items[indexPath.row].idPais{
                    annotation.subtitle = item.nombrePais
                }
            }
            mapa.addAnnotation(annotation)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annot = view.annotation
        let aView = UIView(frame: CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: 325, height:200))
        let DialogView = Dialog(frame: CGRect(x: 0, y: 10, width: aView.frame.width, height: 200))
        let popoverView = Popover(options: nil, showHandler: nil, dismissHandler: nil)
        DialogView.pais.text = annot?.subtitle!
        DialogView.estado.text = annot?.title!
        DialogView.coordenadas.text = String(annot!.coordinate.longitude)
        DialogView.latitud.text = String(annot!.coordinate.latitude)
        aView.addSubview(DialogView)
        popoverView.show(aView, fromView: view)
        
    }
}
