# Extension

[English](README.md) | [中文文档](README_CN.md)

FoxTerm APP 专用 Swift Foundation 扩展库，提供类型转换、字节操作、颜色、网络、日期等常用扩展方法。

> 本库为 [FoxTerm](https://foxterm.app/) APP 专用核心组件，欢迎下载使用：[https://foxterm.app/](https://foxterm.app/)

## 模块

| 文件 | 功能 |
|------|------|
| `Buffer.swift` | 泛型 C 缓冲区封装（`Buffer<T>`、`BufferData<V, L>`） |
| `Bytes.swift` | 字节单位格式化（IEC 二进制 / SI 十进制 / 速率） |
| `String+.swift` | UTF-8 字节转换、C 字符串安全互操作、十六进制颜色 |
| `Data+.swift` | Data ↔ String/Bool/Hex 转换、C 指针安全访问 |
| `Integer+.swift` | 整数类型安全转换（int16/int32/int64/uint32 等截断保护） |
| `CChar+.swift` | CChar 指针 → String 安全转换 |
| `RawPointer+.swift` | 原始指针便捷扩展 |
| `Color+.swift` | SwiftUI Color 扩展（RGB/HSB 组件提取） |
| `Color+HEX.swift` | 十六进制颜色字符串 ↔ Color 互转 |
| `IP.swift` | IP 地址类型别名与私有地址判断（IPv4/IPv6） |
| `Net.swift` | 域名解析、host:port 拼接、网卡信息获取 |
| `Bundle.swift` | Bundle 信息便捷访问 |
| `OutputStream+.swift` | OutputStream 写入扩展 |
| `Task+.swift` | Swift Concurrency Task 扩展 |
| `DateExtensions.swift` | 日期格式化与解析 |
| `DateHelper.swift` | 日期辅助工具 |
| `io.swift` | 文件 I/O 与路径工具（knownHosts 等） |

## 环境要求

| 平台 | 最低版本 |
|------|---------|
| iOS  | 17.0    |
| macOS | 14.0   |
| Swift | 5.10   |

## 安装

```ruby
pod 'Extension', :git => 'https://github.com/foxterm/Extension.git'
```

### 依赖

- [libetos](https://github.com/foxterm/libetos) — C 缓冲区底层实现

## 使用

### Buffer — C 内存缓冲区

```swift
let buf = Buffer<CChar>(64)      // 64 个 CChar 容量
let ptr = buf.buffer              // UnsafeMutablePointer<CChar>
let data = buf.data(32)           // 读取前 32 字节为 Data

// 组合长度+数据缓冲区
let pair = BufferData<UInt8, UInt32>(4096)
pair.len.buffer.pointee = UInt32(receivedBytes)
let payload = pair.data           // 按 len 值读取 Data
```

### Bytes — 字节格式化

```swift
let bytes = Bytes.shared
bytes.format(31323)              // "30.59KiB"（默认 IEC 二进制）
bytes.formatBinary(1048576)      // "1.00MiB"
bytes.formatDecimal(1000000)     // "1.00MB"
bytes.formatRate(1500000)        // "1.50Mbps"
```

### String 扩展

```swift
"hello".bytesData                // Data (UTF-8)
"hello".bytesArray               // [UInt8]（带 \0，用于 C 接口）
"hello".cStringBytes             // [CChar]（带 \0）

// 安全的 C 指针访问（自动释放）
"hello".withCStringPointer { ptr in
    c_function(ptr)
}

// 十六进制颜色
"#FF5733".color                  // Color
```

### Data 扩展

```swift
data.string                      // UTF-8 String?
data.hex                         // 十六进制字符串
data.bool                        // 单字节 → Bool
```

### Integer 扩展

```swift
let value: Int = 42
value.int32                      // Int32（截断保护）
value.uint32                     // UInt32
value.int64                      // Int64
value.bytes                      // [UInt8] 原始字节

// 安全指针访问
value.withUnsafeRawPointer { ptr in
    // 使用 UnsafeRawPointer
}
```

### IP 与网络

```swift
"192.168.1.1".isPrivateIPv4     // true
"fc00::1".isPrivateIPv6         // true

// 域名解析
let ips = await Net.resolveDomainName("example.com")

// 拼接 host:port（自动处理 IPv6 方括号）
Net.joinHostPort(host: "::1", port: 22)  // "[::1]:22"

// 获取网卡信息
let interfaces = Net.getUniqueInterfaces()
// [{ name: "en0", ip: "192.168.1.100" }]
```

### Color 扩展

```swift
Color(hex: "#FF5733")            // Color from HEX
color.hexString                  // "#FF5733"
color.rgb                        // (r: Double, g: Double, b: Double)
```

## 许可证

MIT
