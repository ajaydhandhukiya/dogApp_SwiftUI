//
//  NetworkManager.swift
//  DogsApp
//
//  Created by Ajay Dhandhukiya on 23/05/23.
//
import UIKit

class APIService {

    static let shared = APIService()

    private init() {}
    func makeAPIRequest<T: Codable>(url: String, method: String?, parameters: [String: Any]?, headers: [String: String]?) async throws -> T {
            guard let url = URL(string: url) else {
                throw URLError(.badURL)
            }

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            urlRequest.allHTTPHeaderFields = headers

            if let parameters = parameters {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            }

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            return result
        }
}
