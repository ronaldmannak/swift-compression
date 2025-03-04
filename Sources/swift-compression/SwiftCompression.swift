//
//  SwiftCompression.swift
//
//
//  Created by Evan Anderson on 12/9/24.
//

// MARK: Collection
public extension Collection where Element == UInt8 {
    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed<T: Compressor>(using technique: T) throws -> CompressionResult<[UInt8]> {
        return try technique.compress(data: self)
    }

    /// Decompress the sequence of bytes using the specified technique(s).
    /// 
    /// - Returns: The decompressed bytes.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressed<T: Compressor>(using technique: T) throws -> [UInt8] where T.DecompressClosureParameters == UInt8 {
        return try technique.decompress(data: [UInt8](self))
    }
}

// MARK: [UInt8]
public extension Array where Element == UInt8 {
    /// Compress this data using the specified technique.
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func compress<T: Compressor>(using technique: T) throws -> Self {
        self = try technique.compress(data: self).data
        return self
    }

    /// Decompress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func decompress<T: Compressor>(using technique: T) throws -> Self where T.DecompressClosureParameters == UInt8 {
        self = try technique.decompress(data: self)
        return self
    }
}

// MARK: AsyncThrowingStream
public extension Collection where Element == UInt8 {
    /// Decompress this data to a stream using the specified technique(s).
    /// 
    /// - Parameters:
    ///   - bufferingPolicy: A strategy that handles exhaustion of a buffer’s capacity.
    /// - Returns: An `AsyncStream<UInt8>` that receives a decompressed byte.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompress<T: Compressor>(
        using technique: T,
        bufferingPolicy limit: AsyncThrowingStream<UInt8, Error>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncThrowingStream<UInt8, Error> where T.DecompressClosureParameters == UInt8 {
        return AsyncThrowingStream { continuation in
            defer { continuation.finish() }
            do {
                try technique.decompress(data: self, continuation: continuation)
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
}

#if canImport(Foundation)
// MARK: Foundation
import Foundation

public extension Data {
    /// Compress this data using the specified technique(s).
    /// 
    /// - Returns: `self`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @discardableResult
    @inlinable
    mutating func compress<T: Compressor>(using technique: T) throws -> Self where T.CompressClosureParameters == UInt8 {
        self = try Data(technique.compress(data: [UInt8](self)).data)
        return self
    }

    /// Compress a copy of this data using the specified technique(s).
    /// 
    /// - Returns: The `CompressionResult`.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed<T: Compressor>(using technique: T) throws -> CompressionResult<[UInt8]> where T.CompressClosureParameters == UInt8 {
        return try technique.compress(data: [UInt8](self))
    }

    /// Decompress this data using the specified technique(s).
    /// - Returns: The decompressed data.
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func decompressed<T: Compressor>(using technique: T) throws -> Data where T.DecompressClosureParameters == UInt8 {
        return try Data(technique.decompress(data: [UInt8](self)))
    }
}

public extension StringProtocol {
    /// - Complexity: Varies by technique; minimum of O(_n_) where _n_ is the length of the sequence.
    @inlinable
    func compressed<T: Compressor>(using technique: T, encoding: String.Encoding = .utf8) throws -> CompressionResult<[UInt8]> where T.CompressClosureParameters == UInt8 {
        guard let data:Data = self.data(using: encoding) else { throw CompressionError.failedConversionOfStringToFoundationData }
        return try data.compressed(using: technique)
    }
}

#endif