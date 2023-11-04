//
//  ViewModelEstados.swift
//  Practica iOS
//
//  Created by Etwan on 03/11/23.
//

import Foundation

class ViewModelEstados: NSObject {
    
    private var currentElement = ""
    private var currentID: String = ""
    private var currentName: String = ""
    private var currentCoordinate: String = ""
    private var currentIDEstado: String = ""
    private var parserCompletionHandler: (([Estados])-> Void)?
    
    var dataSource: [String] = []
    
    var refreshData = {() -> () in }
    var items : [Estados] = [] {
        didSet {
            refreshData()
        }
    }
    //Obtener los datos de la API
    func getData(idEstado: String){
        guard let url = URL(string: "https://servicesoap.azurewebsites.net/ws/Paises.asmx?WSDL") else { return }
        let header = [
            "content-type":"text/xml"
        ]
        let param = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetEstadosbyPais xmlns='http://tempuri.org/'><idEstado>\(idEstado)</idEstado></GetEstadosbyPais></soap:Body></soap:Envelope>"
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = header
        request.httpMethod = "POST"
        request.httpBody = param.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error?.localizedDescription ?? "try again")
                }else {
                    if data != nil {
                        if let data_str = String(data: data!, encoding: .utf8){
                            
                            self.dataSource.removeAll()
                            self.items.removeAll()
                            
                            let XMLparser = XMLParser(data: data!)
                            XMLparser.delegate = self
                            XMLparser.parse()
                            
                            print(self.items)
                        }
                    }
                }
            }
        }.resume()
    }
}

extension ViewModelEstados: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "Estado" {
            currentID = ""
            currentName = ""
            currentCoordinate = ""
            currentIDEstado = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "idPais":
            currentID += string
        case "idEstado":
            currentIDEstado += string
        case "Coordenadas":
            currentCoordinate += string
        case "EstadoNombre":
            currentName += string
            self.dataSource.append(string)
            default:
                break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Estado"{
            let estadoItem = Estados(idEstado: currentIDEstado, nombreEstado: currentName, coordenadasEstado: currentCoordinate, idPais: currentID)
            items.append(estadoItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(items)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}

