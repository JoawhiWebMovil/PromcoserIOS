//
//  ViewController.swift
//  PromcoserIOS
//
//  Created by Joaquin Delgado Lorino on 21/11/24.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        iniciarSesion()
    }

    func iniciarSesion() {
        let user = "admin"
        let password = "123"
        
        // Crear la solicitud de login
        let request = LogInRequest(usuario: user, contrasena: password)
        
        // Llamar a la función de red
        NetworkAPI().executeRequest(request: request, token: nil) { (result: Result<LogInResponse, NetworkAPIError>) in
            switch result {
            case .success(let response):
                print("Login exitoso. Token: \(response.token), Nombre: \(response.nombre), Correo: \(response.correoElectronico)")
                self.getCliente(token: response.token)
            case .failure(let error):
                print("Error en el login: \(error)")
            }
        }
    }
    
    func getCliente(token: String) {
        let request = ClienteRequest()
        
        NetworkAPI().executeRequest(request: request, token: token) { (result: Result<ClienteResponse, NetworkAPIError>) in
            switch result {
            case .success(let response):
                print("Equisde", response)
            case .failure(let error):
                print("Error en el login: \(error)")
            }
        }
    }

}

