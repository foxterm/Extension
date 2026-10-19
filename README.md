# Extension

[English](README.md) | [中文文档](README_CN.md)

A dedicated Swift Foundation extension library for the FoxTerm APP, providing commonly used extension methods for type conversion, byte operations, color, networking, date handling, and more.

> This library is a dedicated core component for the [FoxTerm](https://foxterm.app/) APP. Feel free to download it: [https://foxterm.app/](https://foxterm.app/)

## Modules

| File | Description |
|------|-------------|
| `Buffer.swift` | Generic C buffer wrapper (`Buffer<T>`, `BufferData<V, L>`) |
| `Bytes.swift` | Byte unit formatting (IEC binary / SI decimal / rate) |
| `String+.swift` | UTF-8 byte conversion, C string safe interop, hex color |
| `Data+.swift` | Data ↔ String/Bool/Hex conversion, C pointer safe access |
| `Integer+.swift` | Safe integer type conversion (truncation protection for int16/int32/int64/uint32, etc.) |
| `CChar+.swift` | CChar pointer → String safe conversion |
| `RawPointer+.swift` | Raw pointer convenience extensions |
| `Color+.swift` | SwiftUI Color extensions (RGB/HSB component extraction) |
| `Color+HEX.swift` | Hex color string ↔ Color conversion |
| `IP.swift` | IP address type aliases and private address detection (IPv4/IPv6) |
| `Net.swift` | Domain resolution, host:port joining, network interface info |
| `Bundle.swift` | Bundle info convenience access |
| `OutputStream+.swift` | OutputStream write extensions |
| `Task+.swift` | Swift Concurrency Task extensions |
| `DateExtensions.swift` | Date formatting and parsing |
| `DateHelper.swift` | Date helper utilities |
| `io.swift` | File I/O and path utilities (knownHosts, etc.) |

## Requirements

| Platform | Minimum Version |
|----------|-----------------|
| iOS      | 17.0            |
| macOS    | 14.0            |
| Swift    | 5.10            |

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/foxterm/Extension.git", branch: "main"),
```

```swift
.product(name: "Extension", package: "Extension"),
```

### CocoaPods

```ruby
pod 'Extension', :git => 'https://github.com/foxterm/Extension.git'
```

### Dependencies

- [libetos](https://github.com/foxterm/libetos) — C buffer underlying implementation

## Usage

### Buffer — C Memory Buffer

```swift
let buf = Buffer<CChar>(64)      // 64 CChar capacity
let ptr = buf.buffer              // UnsafeMutablePointer<CChar>
let data = buf.data(32)           // Read first 32 bytes as Data

// Combined length + data buffer
let pair = BufferData<UInt8, UInt32>(4096)
pair.len.buffer.pointee = UInt32(receivedBytes)
let payload = pair.data           // Read Data by len value
```

### Bytes — Byte Formatting

```swift
let bytes = Bytes.shared
bytes.format(31323)              // "30.59KiB" (IEC binary by default)
bytes.formatBinary(1048576)      // "1.00MiB"
bytes.formatDecimal(1000000)     // "1.00MB"
bytes.formatRate(1500000)        // "1.50Mbps"
```

### String Extensions

```swift
"hello".bytesData                // Data (UTF-8)
"hello".bytesArray               // [UInt8] (with \0, for C interfaces)
"hello".cStringBytes             // [CChar] (with \0)

// Safe C pointer access (auto-released)
"hello".withCStringPointer { ptr in
    c_function(ptr)
}

// Hex color
"#FF5733".color                  // Color
```

### Data Extensions

```swift
data.string                      // UTF-8 String?
data.hex                         // Hex string
data.bool                        // Single byte → Bool
```

### Integer Extensions

```swift
let value: Int = 42
value.int32                      // Int32 (truncation protection)
value.uint32                     // UInt32
value.int64                      // Int64
value.bytes                      // [UInt8] raw bytes

// Safe pointer access
value.withUnsafeRawPointer { ptr in
    // Use UnsafeRawPointer
}
```

### IP & Networking

```swift
"192.168.1.1".isPrivateIPv4     // true
"fc00::1".isPrivateIPv6         // true

// Domain resolution
let ips = await Net.resolveDomainName("example.com")

// Join host:port (automatically handles IPv6 brackets)
Net.joinHostPort(host: "::1", port: 22)  // "[::1]:22"

// Get network interface info
let interfaces = Net.getUniqueInterfaces()
// [{ name: "en0", ip: "192.168.1.100" }]
```

### Color Extensions

```swift
Color(hex: "#FF5733")            // Color from HEX
color.hexString                  // "#FF5733"
color.rgb                        // (r: Double, g: Double, b: Double)
```

## License

MIT
