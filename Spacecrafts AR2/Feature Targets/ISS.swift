import Foundation

struct ISSPosition: Codable {
    let latitude: Double
    let longitude: Double

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
    }
}

func fetchISSLocation(completion: @escaping (ISSPosition?) -> Void) {
    let urlString = "https://qs80ms8u7c.execute-api.us-east-2.amazonaws.com/prod/iss-location"
    guard let url = URL(string: urlString) else {
        print("❌ Invalid URL")
        completion(nil)
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
        "url": urlString
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
        print("❌ Error creating request body: \(error)")
        completion(nil)
        return
    }
    
    print("🛸 Posting URL to Lambda...")
    
    URLSession.shared.dataTask(with: request) { _, _, error in
        if let error = error {
            print("❌ POST Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        print("✅ URL posted successfully, fetching latest position...")
        
        let getUrl = "https://qs80ms8u7c.execute-api.us-east-2.amazonaws.com/prod/iss-location"
        guard let dynamoUrl = URL(string: getUrl) else {
            print("❌ Invalid DynamoDB URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: dynamoUrl) { data, response, error in
            if let error = error {
                print("❌ GET Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let data = data {
                do {
                    print("📡 Raw response: \(String(data: data, encoding: .utf8) ?? "none")")
                    
                    let position = try JSONDecoder().decode(ISSPosition.self, from: data)
                    print("""
                        ✅ ISS Data Retrieved:
                           Latitude:  \(position.latitude)°
                           Longitude: \(position.longitude)°
                        """)
                    completion(position)
                } catch {
                    print("❌ Decoding Error: \(error)")
                    completion(nil)
                }
            }
        }.resume()
    }.resume()
}
