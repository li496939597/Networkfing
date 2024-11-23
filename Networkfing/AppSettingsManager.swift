import Foundation
import Network
import UIKit

// 单例类，用于处理APP启动时的逻辑
@objc public class AppSettingsManager: NSObject {
    
    // 单例模式，保证全局只有一个AppSettingsManager实例
    @objc public static let shared = AppSettingsManager()
    
    private override init() {
        super.init()
    }
    
    // 判断设备网络是否畅通，使用 Network.framework
    @objc public func isNetworkReachable() -> Bool {
        //print("正在检查网络连接状态...")
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        let semaphore = DispatchSemaphore(value: 0)
        var isReachable = false
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isReachable = true
                //print("网络连接正常")
            } else {
                isReachable = false
                //print("网络连接不可用")
            }
            semaphore.signal()
            monitor.cancel()
        }
        
        monitor.start(queue: queue)
        
        // 等待网络状态更新
        semaphore.wait()
        
        return isReachable
    }
    
    /// 处理应用的启动逻辑。
    ///
    /// - Parameters:
    ///   - appID: 应用的唯一标识符。
    ///   - appKey: 应用的密钥，用于验证。
    ///   - fileName: 存储启动信息的文件名。
    ///   - fileExtension: 文件扩展名。
    /// - Returns: 一个包含修改后的 `appID` 和 `appKey` 的数组。
    /// - Note: 如果是首次启动，会生成一个随机数并写入文件。
    @objc public func handleAppLaunch(appID: String, appKey: String, fileName: String, fileExtension: String) -> [String] {
        //print("正在处理APP启动逻辑...")
        
        // 获取存储文件的路径
        let filePath = self.getFilePath(fileName: fileName, fileExtension: fileExtension)
        
        // 判断文件是否存在，来区分是否是第一次启动
        if FileManager.default.fileExists(atPath: filePath.path) {
            //print("文件存在，执行多次启动逻辑...")
            
            // 读取文件内容并处理
            do {
                let storedNumber = try String(contentsOf: filePath, encoding: .utf8)
                //print("从文件中读取到的随机数：\(storedNumber)")
                
                if let randomNumber = Int(storedNumber) {
                    // 根据读取到的随机数修改appID和appKey
                    let modifiedAppInfo = self.modifyAppInfoIfNeeded(appID: appID, appKey: appKey, randomNumber: randomNumber)
                    return modifiedAppInfo
                }
            } catch {
                //print("文件读取失败，执行首次启动逻辑")
            }
        } else {
            //print("文件不存在，执行首次启动逻辑...")
        }
        
        // 判断网络状态并生成不同范围的随机数
        let networkIsReachable = isNetworkReachable()
        let randomNumber = networkIsReachable ? Int.random(in: 51..<101) : Int.random(in: 0..<51)
        
        // 输出生成的随机数
        //print("生成的随机数：\(randomNumber)")
        
        // 将随机数写入到指定文件
        let numberToStore = String(randomNumber)
        do {
            try numberToStore.write(to: filePath, atomically: true, encoding: .utf8)
            //print("随机数已成功存储到文件：\(filePath.path)")
        } catch {
            //print("写入文件失败：\(error.localizedDescription)")
        }
        
        // 根据随机数范围修改appID和appKey
        let modifiedAppInfo = self.modifyAppInfoIfNeeded(appID: appID, appKey: appKey, randomNumber: randomNumber)
        
        // 输出修改后的appID和appKey
        //print("修改后的appID：\(modifiedAppInfo[0]), 修改后的appKey：\(modifiedAppInfo[1])")
        
        // 返回修改后的appID和appKey
        return modifiedAppInfo
    }
    
    // 根据随机数修改appID和appKey，随机替换字符
    private func modifyAppInfoIfNeeded(appID: String, appKey: String, randomNumber: Int) -> [String] {
        if randomNumber > 50 {
            // 随机替换appID或appKey的字符
            let modifiedAppID = self.modifyStringRandomly(appID)
            let modifiedAppKey = self.modifyStringRandomly(appKey)
            return [modifiedAppID, modifiedAppKey]
        } else {
            return [appID, appKey]
        }
    }
    
    // 随机修改字符串中的一个字符
    private func modifyStringRandomly(_ string: String) -> String {
        // 检查字符串长度，避免索引越界
        guard !string.isEmpty else {
            //print("字符串为空，无法修改")
            return string
        }
        
        // 随机生成索引，保证在字符的有效范围内
        let randomIndexOffset = Int.random(in: 0..<string.count)
        let index = string.index(string.startIndex, offsetBy: randomIndexOffset)
        
        // 随机选择一个字符来替换
        let randomCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".randomElement()!
        
        // 创建修改后的字符串
        var modifiedString = string
        modifiedString.replaceSubrange(index...index, with: String(randomCharacter))
        
        //print("修改后的字符串：\(modifiedString)")
        
        return modifiedString
    }
    
    // 获取文件路径（Document目录下的文件）
    private func getFilePath(fileName: String, fileExtension: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
    }
    /// 处理应用启动逻辑（带应用检查）。
    ///
    /// 此函数会根据启动时的网络状态和设备上是否安装了某些应用来生成随机数，
    /// 并动态修改 `appID` 和 `appKey` 的值。
    ///
    /// - Parameters:
    ///   - appID: 应用的唯一标识符。
    ///   - appKey: 应用的密钥，用于验证。
    ///   - fileName: 存储启动信息的文件名。
    ///   - fileExtension: 文件扩展名。
    /// - Returns: 一个包含修改后的 `appID` 和 `appKey` 的数组。
    /// - 注意:
    ///   - 如果是首次启动，会生成一个随机数并写入到文件中；
    ///   - 如果是多次启动，会读取文件中的随机数并执行对应逻辑。
    ///   - 如果网络不可用且未安装指定应用，随机数生成范围为 `51~100`；
    ///     如果已安装指定应用，生成范围为 `0~50`
    @objc public func handleAppLaunchWithAppCheck(appID: String, appKey: String, fileName: String, fileExtension: String) -> [String] {
        //print("正在处理APP启动逻辑（带应用检查）...")
        
        // 检查Info.plist中是否声明必要的URL Schemes
        checkRequiredSchemes(["weixin", "mqq", "kwai", "snssdk1128","iosamap","baidumap"])
        
        // 获取存储文件的路径
        let filePath = self.getFilePath(fileName: fileName, fileExtension: fileExtension)
        
        // 判断文件是否存在，区分首次或多次启动
        if FileManager.default.fileExists(atPath: filePath.path) {
            //print("文件存在，执行多次启动逻辑...")
            
            // 读取文件内容并处理
            do {
                let storedNumber = try String(contentsOf: filePath, encoding: .utf8)
                //print("从文件中读取到的随机数：\(storedNumber)")
                
                if let randomNumber = Int(storedNumber) {
                    // 根据读取到的随机数修改appID和appKey
                    let modifiedAppInfo = self.modifyAppInfoIfNeeded(appID: appID, appKey: appKey, randomNumber: randomNumber)
                    return modifiedAppInfo
                }
            } catch {
                print("文件读取失败，执行首次启动逻辑")
            }
        } else {
            print("文件不存在，执行首次启动逻辑...")
        }
        
        var randomNumber: Int
        
        // 网络状态未知，按照网络不可用的逻辑处理
        //print("网络状态未知，判断已安装的应用")
        if !isNetworkReachable() {
            let appsToCheck = ["weixin://", "mqq://", "kwai://", "snssdk1128://", "iosamap://", "baidumap://"]
            let isAnyAppInstalled = checkInstalledApps(appSchemes: appsToCheck)
            
            if isAnyAppInstalled {
                print("网络不可用，且已安装指定应用")
                randomNumber = Int.random(in: 0..<51)
            } else {
                print("网络不可用，且未安装指定应用")
                randomNumber = Int.random(in: 51..<101)
            }
        } else {
            print("网络可用，但状态未知")
            randomNumber = Int.random(in: 51..<101)
        }
        
        
        // 输出生成的随机数
        //print("生成的随机数：\(randomNumber)")
        
        // 将随机数写入到指定文件
        let numberToStore = String(randomNumber)
        do {
            try numberToStore.write(to: filePath, atomically: true, encoding: .utf8)
            print("数字已成功存储到文件：\(filePath.path)")
        } catch {
            print("写入文件失败：\(error.localizedDescription)")
            return ["Error", "Error"] // 返回错误标识
        }
        
        // 根据随机数范围修改appID和appKey
        let modifiedAppInfo = self.modifyAppInfoIfNeeded(appID: appID, appKey: appKey, randomNumber: randomNumber)
        
        // 输出修改后的appID和appKey
        //print("修改后的appID：\(modifiedAppInfo[0]), 修改后的appKey：\(modifiedAppInfo[1])")
        
        // 返回修改后的appID和appKey
        return modifiedAppInfo
    }
    
    private func checkRequiredSchemes(_ requiredSchemes: [String]) {
        guard let infoPlist = Bundle.main.infoDictionary,
              let declaredSchemes = infoPlist["LSApplicationQueriesSchemes"] as? [String] else {
            fatalError("未找到 LSApplicationQueriesSchemes，请在主程序的 Info.plist 中添加该键。")
        }
        
        // 找出 Info.plist 中未声明的 URL Schemes
        let missingSchemesInPlist = requiredSchemes.filter { !declaredSchemes.contains($0) }
        
        // 检查设备上未安装的应用（即 canOpenURL 失败的 URL Schemes）
        var installedSchemes: [String] = []
        var notInstalledSchemes: [String] = []
        
        for scheme in requiredSchemes {
            if let url = URL(string: "\(scheme)://"), UIApplication.shared.canOpenURL(url) {
                installedSchemes.append(scheme)
            } else {
                notInstalledSchemes.append(scheme)
            }
        }
        
        // 打印缺失的和已安装的 URL Schemes
        print("已安装的应用 URL Schemes: \(installedSchemes.joined(separator: ", "))")
        print("缺失的 URL Schemes 声明: \(missingSchemesInPlist.joined(separator: ", "))")
        print("设备未安装的应用 URL Schemes: \(notInstalledSchemes.joined(separator: ", "))")
        
        // 如果 Info.plist 缺失必要的 URL Schemes，触发致命错误
        if !missingSchemesInPlist.isEmpty {
            let errorMessage = """
            缺少以下必要的 URL Scheme 声明：
            \(missingSchemesInPlist.joined(separator: ", "))
            请在主程序的 Info.plist 中添加这些声明以确保功能正常运行。
            """
            fatalError(errorMessage)
        }
    }


    
    private var schemeCheckCache: [String: Bool] = [:] // 类属性缓存
    
    private func checkInstalledApps(appSchemes: [String]) -> Bool {
        return appSchemes.contains { scheme in
            if let cachedResult = schemeCheckCache[scheme] {
                return cachedResult
            }
            guard let url = URL(string: scheme) else {
                //print("无效的 URL Scheme: \(scheme)")
                return false
            }
            
            var canOpen = false
            if Thread.isMainThread {
                canOpen = UIApplication.shared.canOpenURL(url)
            } else {
                DispatchQueue.main.sync {
                    canOpen = UIApplication.shared.canOpenURL(url)
                }
            }
            schemeCheckCache[scheme] = canOpen
            return canOpen
        }
    }
}

// 第二个单例：用于每次外部调用时进行网络状态判断
@objc public class NetworkManager: NSObject {
    
    // 单例模式，保证全局只有一个NetworkManager实例
    @objc public static let shared = NetworkManager()
    
    private override init() {
        super.init()
    }
    
    // 判断当前设备的网络是否可用
    @objc public func isNetworkAvailable() -> Bool {
        print("检查网络连接状态...")
        
        // 使用 AppSettingsManager 来判断网络是否可达
        let networkIsAvailable = AppSettingsManager.shared.isNetworkReachable()
        
        // 输出网络状态
        if networkIsAvailable {
            print("网络连接正常")
        } else {
            print("网络连接不可用")
        }
        
        return networkIsAvailable
    }
}
