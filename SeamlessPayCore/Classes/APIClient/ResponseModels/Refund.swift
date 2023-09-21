// **
// * Copyright (c) Seamless Payments, Inc.
// *
// * This source code is licensed under the MIT license found in the
// * LICENSE file in the root directory of this source tree.
// *

// MARK: - Refund
@objcMembers public class Refund: NSObject, Codable {
  let accountType: String?
  let amount: String?
  let authCode: String?
  let batchID: String?
  let createdAt: String?
  let currency: String?
  let events: [Event]?
  let id: String?
  let idempotencyKey: String?
  let ipAddress: String?
  let lastFour: String?
  let metadata: String?
  let method: String?
  let paymentNetwork: String?
  let status: String?
  let statusCode: String?
  let statusDescription: String?
  let token: String?
  let transactionDate: Date?
  let updatedAt: String?

  enum CodingKeys: String, CodingKey {
    case accountType
    case amount
    case authCode
    case batchID = "batchId"
    case createdAt
    case currency
    case events
    case id
    case idempotencyKey
    case ipAddress
    case lastFour
    case metadata
    case method
    case paymentNetwork
    case status
    case statusCode
    case statusDescription
    case token
    case transactionDate
    case updatedAt
  }

  init(
    accountType: String?,
    amount: String?,
    authCode: String?,
    batchID: String?,
    createdAt: String?,
    currency: String?,
    events: [Event]?,
    id: String?,
    idempotencyKey: String?,
    ipAddress: String?,
    lastFour: String?,
    metadata: String?,
    method: String?,
    paymentNetwork: String?,
    status: String?,
    statusCode: String?,
    statusDescription: String?,
    token: String?,
    transactionDate: Date?,
    updatedAt: String?
  ) {
    self.accountType = accountType
    self.amount = amount
    self.authCode = authCode
    self.batchID = batchID
    self.createdAt = createdAt
    self.currency = currency
    self.events = events
    self.id = id
    self.idempotencyKey = idempotencyKey
    self.ipAddress = ipAddress
    self.lastFour = lastFour
    self.metadata = metadata
    self.method = method
    self.paymentNetwork = paymentNetwork
    self.status = status
    self.statusCode = statusCode
    self.statusDescription = statusDescription
    self.token = token
    self.transactionDate = transactionDate
    self.updatedAt = updatedAt
  }
}

// MARK: Refund convenience initializers and mutators

extension Refund {
  convenience init(data: Data) throws {
    let me = try newJSONDecoder().decode(Refund.self, from: data)
    self.init(
      accountType: me.accountType,
      amount: me.amount,
      authCode: me.authCode,
      batchID: me.batchID,
      createdAt: me.createdAt,
      currency: me.currency,
      events: me.events,
      id: me.id,
      idempotencyKey: me.idempotencyKey,
      ipAddress: me.ipAddress,
      lastFour: me.lastFour,
      metadata: me.metadata,
      method: me.method,
      paymentNetwork: me.paymentNetwork,
      status: me.status,
      statusCode: me.statusCode,
      statusDescription: me.statusDescription,
      token: me.token,
      transactionDate: me.transactionDate,
      updatedAt: me.updatedAt
    )
  }

  convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }

  func jsonData() throws -> Data {
    try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    try String(data: jsonData(), encoding: encoding)
  }
}

// MARK: - Event
@objcMembers class Event: NSObject, Codable {
  let delta: String?
  let createdAt: String?
  let eventDelta: String?
  let offlineCreatedAt: String?
  let status: String?
  let statusCode: String?
  let statusDescription: String?
  let type: String?

  enum CodingKeys: String, CodingKey {
    case delta = "_delta"
    case createdAt
    case eventDelta = "delta"
    case offlineCreatedAt
    case status
    case statusCode
    case statusDescription
    case type
  }

  init(
    delta: String?,
    createdAt: String?,
    eventDelta: String?,
    offlineCreatedAt: String?,
    status: String?,
    statusCode: String?,
    statusDescription: String?,
    type: String?
  ) {
    self.delta = delta
    self.createdAt = createdAt
    self.eventDelta = eventDelta
    self.offlineCreatedAt = offlineCreatedAt
    self.status = status
    self.statusCode = statusCode
    self.statusDescription = statusDescription
    self.type = type
  }
}

// MARK: Event convenience initializers and mutators

extension Event {
  convenience init(data: Data) throws {
    let me = try newJSONDecoder().decode(Event.self, from: data)
    self.init(
      delta: me.delta,
      createdAt: me.createdAt,
      eventDelta: me.eventDelta,
      offlineCreatedAt: me.offlineCreatedAt,
      status: me.status,
      statusCode: me.statusCode,
      statusDescription: me.statusDescription,
      type: me.type
    )
  }

  convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }

  convenience init(fromURL url: URL) throws {
    try self.init(data: Data(contentsOf: url))
  }

  func with(
    delta: String?? = nil,
    createdAt: String?? = nil,
    eventDelta: String?? = nil,
    offlineCreatedAt: String?? = nil,
    status: String?? = nil,
    statusCode: String?? = nil,
    statusDescription: String?? = nil,
    type: String?? = nil
  ) -> Event {
    Event(
      delta: delta ?? self.delta,
      createdAt: createdAt ?? self.createdAt,
      eventDelta: eventDelta ?? self.eventDelta,
      offlineCreatedAt: offlineCreatedAt ?? self.offlineCreatedAt,
      status: status ?? self.status,
      statusCode: statusCode ?? self.statusCode,
      statusDescription: statusDescription ?? self.statusDescription,
      type: type ?? self.type
    )
  }

  func jsonData() throws -> Data {
    try newJSONEncoder().encode(self)
  }

  func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
    try String(data: jsonData(), encoding: encoding)
  }
}

// MARK: - Helper functions for creating encoders and decoders

private var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)
  return .custom {
    var container = $1.singleValueContainer()
    try container.encode(formatter.string(from: $0))
  }
}

private func newJSONDecoder() -> JSONDecoder {
  let decoder = JSONDecoder()
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)

  decoder.dateDecodingStrategy = .custom {
    let container = try $0.singleValueContainer()
    let string = try container.decode(String.self)
    if let date = formatter.date(from: string) {
      return date
    }
    throw DecodingError.dataCorruptedError(
      in: container,
      debugDescription: "Invalid date: \(string)"
    )
  }

  return decoder
}

private func newJSONEncoder() -> JSONEncoder {
  let encoder = JSONEncoder()
  let formatter = ISO8601DateFormatter()
  formatter.formatOptions.insert(.withFractionalSeconds)

  encoder.dateEncodingStrategy = .custom {
    var container = $1.singleValueContainer()
    try container.encode(formatter.string(from: $0))
  }
  return encoder
}
