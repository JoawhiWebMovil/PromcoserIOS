//
//  NetworkAPI.swift
//  PromcoserIOS
//
//  Created by Joaquin Delgado Lorino on 21/11/24.
//

import Foundation

// Protocolo que define la estructura básica de cualquier Request
protocol NetworkRequest {
    associatedtype ResponseType: Codable
    
    var url: String { get }
    var method: HttpMethod { get }
    var body: Codable? { get }
    var headers: [String: String] { get }
}

// Enum para los métodos HTTP (GET, POST, PUT)
enum HttpMethod: String {
    case GET
    case POST
    case PUT
}

// Error personalizado para la red
enum NetworkAPIError: Error {
    case invalidURL
    case requestFailed
    case serverError(statusCode: Int)
    case decodingError
    case unauthorized
    case forbidden
    case unknownError(statusCode: Int)
}

// Clase que realiza las solicitudes de red
class NetworkAPI {
    
    // Función para ejecutar un request que implementa NetworkRequest
    public func executeRequest<T: NetworkRequest>(
        request: T,
        token: String? = nil,
        completion: @escaping (Result<T.ResponseType, NetworkAPIError>) -> Void
    ) {
        // Crear la URL
        guard let url = URL(string: request.url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Crear la solicitud
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Agregar encabezados predeterminados
        var headers = request.headers
        headers["Content-Type"] = "application/json" // Aseguramos que siempre sea JSON

        // Establecer el token si existe
        if let token = token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        // Establecer los encabezados
        headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        // Si hay cuerpo en la solicitud, agregarlo
        if let body = request.body {
            do {
                let jsonData = try JSONEncoder().encode(body)
                urlRequest.httpBody = jsonData
            } catch {
                completion(.failure(.decodingError))
                return
            }
        }
        
        // Realizar la solicitud
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request Error: \(error)")
                completion(.failure(.requestFailed))
                return
            }
            
            // Verificar si la respuesta es válida
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.serverError(statusCode: -1)))
                return
            }
            
            // Manejar códigos de error específicos
            switch httpResponse.statusCode {
            case 200...299:
                break // Código exitoso, continuar con la decodificación
            case 401:
                completion(.failure(.unauthorized)) // Token inválido o falta
                return
            case 403:
                completion(.failure(.forbidden)) // Sin permisos para acceder
                return
            case 500...599:
                completion(.failure(.serverError(statusCode: httpResponse.statusCode))) // Error en el servidor
                return
            default:
                completion(.failure(.unknownError(statusCode: httpResponse.statusCode))) // Otro código no manejado
                return
            }
            
            // Intentar decodificar los datos
            guard let data = data else {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }
                        
            do {
                let decodedResponse = try JSONDecoder().decode(T.ResponseType.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(.decodingError)) // Error al decodificar la respuesta
            }
        }.resume()
    }
}
