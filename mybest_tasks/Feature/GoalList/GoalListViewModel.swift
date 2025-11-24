import Foundation
import Combine
import MyBestAITasksCore

/// 目標一覧画面の ViewModel。
///
/// この ViewModel は目標のリストを管理し、View に公開する。
/// `GoalRepository` を購読して、リストをリアルタイムで更新する。
@MainActor
class GoalListViewModel: ObservableObject {
    /// 目標データにアクセスするためのリポジトリ。
    let repository: GoalRepositoryProtocol
    
    /// ViewModel を初期化する。
    /// - Parameter repository: 目標を取得するためのリポジトリ。
    init(repository: GoalRepositoryProtocol) {
        self.repository = repository
    }
}
