//
//  NetworkManager.swift
//  TextToImage
//
//  Created by Ethan Key on 8/10/24.
//

import Foundation
import UIKit

struct NetworkManager {
    static let shared = NetworkManager()
    private let apiKey = "API_Key"

    func fetchImageFromText(description: String, completion: @escaping (UIImage?, Error?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/images/generations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "prompt": description,
            "n": 1,
            "size": "1024x1024"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(nil, NSError(domain: "DataError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let imageResponse = try decoder.decode(ImageResponse.self, from: data)
                guard let firstImageData = imageResponse.data.first,
                      let imageUrl = URL(string: firstImageData.url) else {
                    throw NSError(domain: "URL Error", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                }

                URLSession.shared.dataTask(with: imageUrl) { imageData, _, error in
                    guard let imageData = imageData, let image = UIImage(data: imageData) else {
                        DispatchQueue.main.async {
                            completion(nil, NSError(domain: "ImageError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"]))
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion(image, nil)
                    }
                }.resume()
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }.resume()
    }
}

struct ImageResponse: Codable {
    let data: [ImageData]
}

struct ImageData: Codable {
    let url: String
}
