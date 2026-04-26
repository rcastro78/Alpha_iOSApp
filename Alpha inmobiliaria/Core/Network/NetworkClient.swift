//
//  NetworkClient.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//
import Foundation

class NetworkClient {
    static let shared = NetworkClient()
    private init() {}

    private var baseURL: URL {
        URL(string: APIConstants.baseURL)!
    }

    func multipartRequest<T: Decodable>(
        endpoint: String,
        fields: [String: String],
        imageData: Data? = nil,
        imageName: String = "foto",
        responseType: T.Type
    ) async throws -> T {

        // ← Concatenación directa, igual que Retrofit
        guard let url = URL(string: APIConstants.baseURL + endpoint) else {
            throw APIError.serverError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for (key, value) in fields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }

        if let imageData {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(imageName)\"; filename=\"\(imageName).jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        request.httpBody = body

        // Debug
        print("📡 URL: \(url.absoluteString)")
        print("📡 Fields: \(fields.keys.joined(separator: ", "))")
        print("📡 Foto: \(imageData != nil ? "Sí (\(imageData!.count) bytes)" : "No")")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let raw = String(data: data, encoding: .utf8) {
            print("📡 Respuesta: \(raw)")
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("❌ HTTP \(code)")
            throw APIError.serverError
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func request<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: [String: String],
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30

        let formBody = body.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = formBody.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let raw = String(data: data, encoding: .utf8) {
            print("📡 Respuesta cruda: \(raw)")
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Error decoding: \(error)")
            throw APIError.decodingError
        }
    }

    func requestJSON<T: Decodable, U: Encodable>(  // ← movido aquí fuera del enum
        endpoint: String,
        method: String = "POST",
        headers: [String: String] = [:],
        body: U,
        responseType: T.Type
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30

        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let raw = String(data: data, encoding: .utf8) {
            print("📡 Respuesta cruda (JSON): \(raw)")
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.serverError
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Error decoding JSON: \(error)")
            throw APIError.decodingError
        }
    }
}

// ← Enum limpio, sin métodos adentro
enum APIError: Error, LocalizedError {
    case serverError
    case decodingError
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverError:  return "Error en la respuesta del servidor"
        case .decodingError: return "Error al procesar la respuesta"
        case .unknown:       return "Error desconocido"
        }
    }
}

// ← Extensión de Data separada
private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) { append(data) }
    }
}
