//
//  LogInRequest.swift
//  PromcoserIOS
//
//  Created by Joaquin Delgado Lorino on 21/11/24.
//

import Foundation

struct LogInRequestBody: Codable {
    let usuario: String
    let contrasena: String
}

struct LogInResponse: Codable {
    let nombre: String
    let apellido: String
    let token: String
    let correoElectronico: String
}

struct LogInRequest: NetworkRequest {
    
    typealias ResponseType = LogInResponse
    
    let usuario: String
    let contrasena: String
    
    var baseURL: String { "https://b7f8-38-25-17-64.ngrok-free.app" }
    
    var path: String { "/api/Personal/LogIn" }
    
    var url: String { baseURL + path }
    
    var method: HttpMethod { .POST }
    
    var body: Codable? { LogInRequestBody(usuario: usuario, contrasena: contrasena) }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json", "ngrok-skip-browser-warning": "true"]
    }
}


