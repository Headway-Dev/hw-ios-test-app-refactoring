import Foundation

struct UserData: Decodable {
    var user: User?
    
    enum CodingKeys: CodingKey {
        case user
    }
}

public struct User: Decodable {
    var id: String?
    var name: String?
    var email: String?
    var fbc: String?
    var fbp: String?
    var language: String?
    var ak: String?
    var createdAt: Data?
    var subscriptionStatus: [String: String?]?
    var ip: String?
    var country: String?
    var isp: String?
    var userAgent: String?
    var appData: [String: String?]?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case email = "Email"
        case fbc = "Fbc"
        case fbp = "Fbp"
        case language = "Language"
        case ak = "AK"
        case createdAt = "CreatedAt"
        case subscriptionStatus = "SubscriptionStatus"
        case ip = "IP"
        case country = "Country"
        case isp = "ISP"
        case userAgent = "UserAgent"
        case appData = "AppData"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try? container.decode(String.self, forKey: .id)
        self.name = try? container.decode(String.self, forKey: .name)
        self.email = try? container.decode(String.self, forKey: .email)
        self.fbc = try? container.decode(String.self, forKey: .fbc)
        self.fbp = try? container.decode(String.self, forKey: .fbp)
        self.language = try? container.decode(String.self, forKey: .language)
        self.ak = try? container.decode(String.self, forKey: .ak)
        self.createdAt = try? container.decode(Data.self, forKey: .language)
        self.subscriptionStatus = try? container.decode([String: String?].self, forKey: .subscriptionStatus)
        self.ip = try? container.decode(String.self, forKey: .ip)
        self.country = try? container.decode(String.self, forKey: .country)
        self.isp = try? container.decode(String.self, forKey: .isp)
        self.userAgent = try? container.decode(String.self, forKey: .userAgent)
        self.appData = try? container.decode([String: String?].self, forKey: .appData)
    }
}
