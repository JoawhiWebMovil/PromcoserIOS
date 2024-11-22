//
//  ClienteRequest.swift
//  PromcoserIOS
//
//  Created by Joaquin Delgado Lorino on 21/11/24.
//

import Foundation

struct Cliente: Codable {
    let nombre: String
    let apellido: String
    let razonSocial: String  // Campo que has mencionado en lugar de token y correo
}

typealias ClienteResponse = [Cliente]

struct ClienteRequest: NetworkRequest {
    
    typealias ResponseType = ClienteResponse
        
    var baseURL: String { "https://b7f8-38-25-17-64.ngrok-free.app" }
    
    var path: String { "/api/Cliente/GetAllActive" }
    
    var url: String { baseURL + path }
    
    var method: HttpMethod { .GET }
    
    var body: Codable? { nil }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json", "ngrok-skip-browser-warning": "true"]
    }
}

