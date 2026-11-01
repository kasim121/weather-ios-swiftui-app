import Foundation

protocol APIClient {
    func get<Response: Decodable>(
        _ url: URL,
        headers: [String: String]
    ) async throws -> Response

    func post<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String]
    ) async throws -> Response

    func put<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String]
    ) async throws -> Response

    func patch<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String]
    ) async throws -> Response

    func delete<Response: Decodable>(
        _ url: URL,
        headers: [String: String]
    ) async throws -> Response
}

enum APIClientError: LocalizedError {
    case invalidResponse
    case encodingFailed
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The server returned an unexpected response."
        case .encodingFailed:
            "The request body could not be encoded."
        case .decodingFailed:
            "The server response could not be read."
        }
    }
}

final class URLSessionAPIClient: APIClient {
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    func get<Response: Decodable>(
        _ url: URL,
        headers: [String: String] = [:]
    ) async throws -> Response {
        try await send(try makeRequest(url: url, method: .get, headers: headers))
    }

    func post<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> Response {
        try await send(try makeRequest(url: url, method: .post, body: body, headers: headers))
    }

    func put<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> Response {
        try await send(try makeRequest(url: url, method: .put, body: body, headers: headers))
    }

    func patch<Body: Encodable, Response: Decodable>(
        _ url: URL,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> Response {
        try await send(try makeRequest(url: url, method: .patch, body: body, headers: headers))
    }

    func delete<Response: Decodable>(
        _ url: URL,
        headers: [String: String] = [:]
    ) async throws -> Response {
        try await send(try makeRequest(url: url, method: .delete, headers: headers))
    }

    private func send<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw APIClientError.invalidResponse
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIClientError.decodingFailed
        }
    }

    private func makeRequest(
        url: URL,
        method: HTTPMethod,
        body: (any Encodable)? = nil,
        headers: [String: String]
    ) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APIClientError.encodingFailed
            }
        }

        return request
    }
}

private enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

private struct AnyEncodable: Encodable {
    private let encodeValue: (Encoder) throws -> Void

    init(_ value: any Encodable) {
        encodeValue = value.encode
    }

    func encode(to encoder: Encoder) throws {
        try encodeValue(encoder)
    }
}
