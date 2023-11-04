//
//  ViewModelPaises.swift
//  Practica iOS
//
//  Created by Etwan on 30/10/23.
//

import Foundation

class ViewModelPaises: NSObject {
    
    private var currentElement = ""
    private var currentID: String = ""
    private var currentName: String = ""
    private var parserCompletionHandler: (([Paises])-> Void)?
    
    var dataSource: [String] = []
    
    var refreshData = {() -> () in }
    var items : [Paises] = [] {
        didSet {
            refreshData()
        }
    }
    
    //Obtener los datos de la API
    func getData(){
        guard let url = URL(string: "https://servicesoap.azurewebsites.net/ws/Paises.asmx?WSDL") else { return }
        let header = [
            "content-type":"text/xml"
        ]
        let param = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema' xmlns:soap='http://schemas.xmlsoap.org/soap/envelope/'><soap:Body><GetPaises xmlns='http://tempuri.org/' /></soap:Body></soap:Envelope>"
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

extension ViewModelPaises: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "Pais" {
            currentID = ""
            currentName = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "idPais":
                currentID += string
            case "NombrePais":
                currentName += string
                self.dataSource.append(string)
            default:
                break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Pais"{
            let paisItem = Paises(idPais: currentID, nombrePais: currentName)
            items.append(paisItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(items)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
}
