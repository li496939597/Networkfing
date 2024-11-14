import Foundation
import Network

// 单例类，用于处理APP启动时的逻辑
@objc public class AppSettingsManager: NSObject {
    
    // 单例模式，保证全局只有一个AppSettingsManager实例
    @objc public static let shared = AppSettingsManager()
    
    private override init() {
        super.init()
    }
    
    // 判断设备网络是否畅通，使用 Network.framework
    @objc public func isNetworkReachable() -> Bool {
        print("正在检查网络连接状态...")
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        var isReachable = false
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isReachable = true
                print("网络连接正常")
            } else {
                isReachable = false
                print("网络连接不可用")
            }
        }
        
        monitor.start(queue: queue)
        
        // 等待网络状态更新
        Thread.sleep(forTimeInterval: 1.0)
        
        return isReachable
    }
    
    // 处理APP启动时的逻辑，合并首次和多次启动逻辑
    @objc public func handleAppLaunch(appID: String, appKey: String, fileName: String, fileExtension: String) -> [String] {
        print("正在处理APP启动逻辑...")
        
        // 获取存储文件的路径
        let filePath = self.getFilePath(fileName: fileName, fileExtension: fileExtension)
        
        // 判断文件是否存在，来区分是否是第一次启动
        if FileManager.default.fileExists(atPath: filePath.path) {
            print("文件存在，执行多次启动逻辑...")
            
            // 读取文件内容并处理
            do {
                let storedNumber = try String(contentsOf: filePath, encoding: .utf8)
                print("从文件中读取到的随机数：\(storedNumber)")
                
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
        
        // 判断网络状态并生成不同范围的随机数
        let networkIsReachable = isNetworkReachable()
        let randomNumber = networkIsReachable ? Int.random(in: 51..<101) : Int.random(in: 0..<51)
        
        // 输出生成的随机数
        print("生成的随机数：\(randomNumber)")
        
        // 将随机数写入到指定文件
        let numberToStore = String(randomNumber)
        do {
            try numberToStore.write(to: filePath, atomically: true, encoding: .utf8)
            print("随机数已成功存储到文件：\(filePath.path)")
        } catch {
            print("写入文件失败：\(error.localizedDescription)")
        }
        
        // 根据随机数范围修改appID和appKey
        let modifiedAppInfo = self.modifyAppInfoIfNeeded(appID: appID, appKey: appKey, randomNumber: randomNumber)
        
        // 输出修改后的appID和appKey
        print("修改后的appID：\(modifiedAppInfo[0]), 修改后的appKey：\(modifiedAppInfo[1])")
        
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
        guard string.count > 0 else {
            print("字符串为空，无法修改")
            return string
        }
        
        // 随机生成索引，保证在字符的有效范围内
        let randomIndex = Int.random(in: 0..<string.count)
        let index = string.index(string.startIndex, offsetBy: randomIndex)
        
        // 随机选择一个字符来替换
        let randomCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".randomElement()!
        
        // 创建修改后的字符串
        var modifiedString = string
        modifiedString.replaceSubrange(index...index, with: String(randomCharacter))
        
        print("修改后的字符串：\(modifiedString)")
        
        return modifiedString
    }

    
    // 获取文件路径（Document目录下的文件）
    private func getFilePath(fileName: String, fileExtension: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
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
