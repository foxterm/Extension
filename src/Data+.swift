// FoxTerm | Data+.swift
// Copyright (c) 2025-2026 foxterm.app
// Created by foxterm@foxmail.com

import Foundation

public extension Data {
    /// 安全地将 Data 转为指向 Int8 的 C 字符串指针(用于兼容 OpenSSL 等 C 接口)。
    func withCPointer<R>(_ body: (UnsafePointer<UInt8>?, Int) -> R) -> R {
        withUnsafeBytes { bufPtr in
            let ptr = bufPtr.baseAddress?.assumingMemoryBound(to: UInt8.self)
            return body(ptr, self.count)
        }
    }

    /// 转换为 UTF-8 编码的 String。
    var string: String? {
        string(encoding: .utf8)
    }

    /// 使用指定的编码方式将 Data 转换为 String。
    /// - Parameter encoding: 字符编码格式。
    /// - Returns: 转换成功返回 String，失败返回 nil。
    func string(encoding: String.Encoding) -> String? {
        String(data: self, encoding: encoding)
    }

    /// 将 Data 转换为 Bool 值。假设 Data 包含单字节，1 表示 true，0 表示 false。
    var bool: Bool {
        guard !isEmpty else { return false }
        let bool: UInt8 = load()
        return bool == 1
    }

    /// 从 Data 中加载并解析指定整型 `T`。
    /// - Returns: 解析出的 `T` 类型数值。
    func load<T: FixedWidthInteger>() -> T {
        guard count >= MemoryLayout<T>.size else { return 0 }
        return withUnsafeBytes { ptr in
            // 使用 loadUnaligned 确保非对齐内存读取的安全，防止崩溃
            ptr.loadUnaligned(fromByteOffset: 0, as: T.self)
        }
    }

    /// 从指定的数值 `T` 创建二进制 Data。
    /// - Parameter v: 需要转换的数值。
    /// - Returns: 包含该数值内存布局的 Data 实例。
    static func from(_ v: inout some FixedWidthInteger) -> Data {
        Swift.withUnsafeBytes(of: &v) { Data($0) }
    }

    /// 从 String 创建 UTF-8 Data。
    static func from(_ value: String) -> Data {
        Data(value.utf8)
    }

    /// 从 Bool 创建 Data(1 字节：1 为 true，0 为 false)。
    static func from(_ value: Bool) -> Data {
        var bool: UInt8 = value ? 1 : 0
        return .from(&bool)
    }

    // MARK: - 图片格式检测扩展

    /// 检查是否为常见的图片格式(包含标量图与常见矢量图/专业图像格式)。
    var isImage: Bool {
        guard count >= 2 else { return false }
        return isJPEG || isPNG || isGIF || isWebP || isBMP || isTIFF || isHEIC || isAVIF
            || isICO || isSVG || isPSD || isJPEG2000 || isEXR
    }

    /// JPEG 格式检测 (SOI Marker: FF D8 FF)。
    var isJPEG: Bool {
        starts(with: [0xFF, 0xD8, 0xFF])
    }

    /// PNG 格式检测 (8 字节魔数: 89 50 4E 47 0D 0A 1A 0A)。
    var isPNG: Bool {
        starts(with: [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
    }

    /// GIF 格式检测(GIF87a / GIF89a)。
    var isGIF: Bool {
        starts(with: [0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) // "GIF87a"
            || starts(with: [0x47, 0x49, 0x46, 0x38, 0x39, 0x61]) // "GIF89a"
    }

    /// WebP 格式检测(RIFF....WEBP)。
    var isWebP: Bool {
        guard count >= 12 else { return false }
        return starts(with: [0x52, 0x49, 0x46, 0x46]) // "RIFF"
            && matchesBytes([0x57, 0x45, 0x42, 0x50], offset: 8) // "WEBP"
    }

    /// BMP 格式检测(BM 标记)。
    var isBMP: Bool {
        starts(with: [0x42, 0x4D]) // "BM"
    }

    /// TIFF 格式检测(支持 Little-Endian "II" 与 Big-Endian "MM")。
    var isTIFF: Bool {
        starts(with: [0x49, 0x49, 0x2A, 0x00]) // II*.
            || starts(with: [0x4D, 0x4D, 0x00, 0x2A]) // MM.*
    }

    /// HEIC / HEIF / AVIF 家族 ISO Base Media File Format 基础校验。
    private func checkISOBMFFBrand(_ brands: [[UInt8]]) -> Bool {
        guard count >= 12 else { return false }
        // 偏移量 4 开始为 'ftyp'
        guard matchesBytes([0x66, 0x74, 0x79, 0x70], offset: 4) else { return false }

        // 检查 Major Brand (offset 8)
        for brand in brands {
            if matchesBytes(brand, offset: 8) {
                return true
            }
        }
        return false
    }

    /// HEIC / HEIF 格式检测。
    var isHEIC: Bool {
        let validBrands: [[UInt8]] = [
            [0x68, 0x65, 0x69, 0x63], // "heic"
            [0x68, 0x65, 0x69, 0x78], // "heix"
            [0x68, 0x65, 0x76, 0x63], // "hevc"
            [0x68, 0x65, 0x76, 0x78], // "hevx"
            [0x6D, 0x69, 0x66, 0x31], // "mif1"
            [0x6D, 0x73, 0x66, 0x31], // "msf1"
        ]
        return checkISOBMFFBrand(validBrands)
    }

    /// AVIF 格式检测 (AV1 Image File Format)。
    var isAVIF: Bool {
        let validBrands: [[UInt8]] = [
            [0x61, 0x76, 0x69, 0x66], // "avif"
            [0x61, 0x76, 0x69, 0x73], // "avis"
        ]
        return checkISOBMFFBrand(validBrands)
    }

    /// ICO / CUR 图标格式检测。
    var isICO: Bool {
        // 前两字节 00 00，第3-4字节为 01 00 (ICO) 或 02 00 (CUR)
        starts(with: [0x00, 0x00, 0x01, 0x00]) || starts(with: [0x00, 0x00, 0x02, 0x00])
    }

    /// SVG 矢量图检测(兼容 UTF-8/ASCII、BOM 头以及长 Header 文本)。
    var isSVG: Bool {
        guard count >= 5 else { return false }

        // 1. 忽略前面的 UTF-8 BOM 标记(0xEF, 0xBB, 0xBF)及常见空白字符
        var searchOffset = 0
        if starts(with: [0xEF, 0xBB, 0xBF]) {
            searchOffset = 3
        }

        // 2. 检查开头是否紧跟 "<svg" 或 "<?xml"(忽略前面的空格/换行)
        // "<svg" 的 ASCII/UTF-8 字节为: 3C 73 76 67
        // "<?xml" 的 ASCII/UTF-8 字节为: 3C 3F 78 6D 6C
        // 扩大采样至 2048 字节，足以涵盖几乎所有正常的 XML 声明和注释
        let maxSampleSize = Swift.min(count - searchOffset, 2048)
        guard maxSampleSize >= 4 else { return false }

        let sampleData = dropFirst(searchOffset).prefix(maxSampleSize)

        // 不依赖 String 编码转换，直接转小写字节数组匹配
        return sampleData.withUnsafeBytes { ptr -> Bool in
            guard let base = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return false }

            // 快速扫描窗口内是否存在 "<svg" 或 "<svg:" (带命名空间)
            // 3C: '<', 73: 's', 76: 'v', 67: 'g' / 53: 'S', 56: 'V', 47: 'G'
            for i in 0 ..< (maxSampleSize - 3) {
                if base[i] == 0x3C { // '<'
                    let b1 = base[i + 1] | 0x20 // 转小写
                    let b2 = base[i + 2] | 0x20
                    let b3 = base[i + 3] | 0x20
                    if b1 == 0x73, b2 == 0x76, b3 == 0x67 { // "svg"
                        return true
                    }
                }
            }
            return false
        }
    }

    /// Photoshop PSD / PSB 格式检测。
    var isPSD: Bool {
        starts(with: [0x38, 0x42, 0x50, 0x53]) // "8BPS"
    }

    /// JPEG 2000 格式检测。
    var isJPEG2000: Bool {
        starts(with: [0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20])
    }

    /// OpenEXR 高动态范围图像检测。
    var isEXR: Bool {
        starts(with: [0x76, 0x2F, 0x31, 0x01])
    }

    /// 辅助方法：检查特定 offset 处的字节匹配，避免产生多余的 Data 内存分配。
    private func matchesBytes(_ bytes: [UInt8], offset: Int) -> Bool {
        guard count >= offset + bytes.count else { return false }
        return withUnsafeBytes { ptr -> Bool in
            guard let baseAddress = ptr.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return false }
            for (i, byte) in bytes.enumerated() {
                if baseAddress[offset + i] != byte {
                    return false
                }
            }
            return true
        }
    }

    // MARK: - 工具方法改进

    /// 从指定索引开始查找目标字节的位置。
    func firstIndex(of element: UInt8, startingAt startIndex: Int) -> Int? {
        guard startIndex < count else { return nil }
        let searchIndex = index(self.startIndex, offsetBy: startIndex)
        if let idx = self[searchIndex...].firstIndex(of: element) {
            return distance(from: self.startIndex, to: idx)
        }
        return nil
    }

    /// 将每个字节转为 Hex 字符串数组(注意：大 Data 消耗较高，推荐直接使用 hexString)。
    var hex: [String] {
        map { String(format: "%02X", $0) }
    }

    /// 高性能转化为大写十六进制字符串(指针优化，避免反复拼接 String)。
    var hexString: String {
        guard !isEmpty else { return "" }
        let hexDigits: [UInt8] = Array("0123456789ABCDEF".utf8)
        var utf8Bytes = [UInt8](repeating: 0, count: count * 2)

        withUnsafeBytes { rawBuffer in
            guard let ptr = rawBuffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return }
            var j = 0
            for i in 0 ..< count {
                let byte = ptr[i]
                utf8Bytes[j] = hexDigits[Int(byte >> 4)]
                utf8Bytes[j + 1] = hexDigits[Int(byte & 0x0F)]
                j += 2
            }
        }

        return String(decoding: utf8Bytes, as: UTF8.self)
    }

    /// 获取数据指纹(长度大于 16 字节使用 Base64，否则使用冒号分隔的十六进制)。
    var fingerprint: String {
        count > 16 ? base64WithoutPadding : hex.joined(separator: ":")
    }

    /// 标准 Base64 字符串。
    var base64String: String {
        base64EncodedString()
    }

    /// 移除等号填充符(Padding '=')的 Base64 字符串。
    var base64WithoutPadding: String {
        base64String.replacingOccurrences(of: "=", with: "")
    }
}
