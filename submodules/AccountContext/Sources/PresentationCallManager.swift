import Foundation
import UIKit
import Postbox
import TelegramCore
import SyncCore
import SwiftSignalKit
import TelegramAudio

public enum RequestCallResult {
    case requested
    case alreadyInProgress(PeerId)
}

public struct PresentationCallState: Equatable {
    public enum State: Equatable {
        case waiting
        case ringing
        case requesting(Bool)
        case connecting(Data?)
        case active(Double, Int32?, Data)
        case reconnecting(Double, Int32?, Data)
        case terminating
        case terminated(CallId?, CallSessionTerminationReason?, Bool)
    }
    
    public enum VideoState: Equatable {
        case notAvailable
        case available(Bool)
        case active
    }
    
    public var state: State
    public var videoState: VideoState
    
    public init(state: State, videoState: VideoState) {
        self.state = state
        self.videoState = videoState
    }
}

public protocol PresentationCall: class {
    var account: Account { get }
    var isIntegratedWithCallKit: Bool { get }
    var internalId: CallSessionInternalId { get }
    var peerId: PeerId { get }
    var isOutgoing: Bool { get }
    var peer: Peer? { get }
    
    var state: Signal<PresentationCallState, NoError> { get }

    var isMuted: Signal<Bool, NoError> { get }
    
    var audioOutputState: Signal<([AudioSessionOutput], AudioSessionOutput?), NoError> { get }
    
    var canBeRemoved: Signal<Bool, NoError> { get }
    
    func answer()
    func hangUp() -> Signal<Bool, NoError>
    func rejectBusy()
    
    func toggleIsMuted()
    func setIsMuted(_ value: Bool)
    func setEnableVideo(_ value: Bool)
    func switchVideoCamera()
    func setCurrentAudioOutput(_ output: AudioSessionOutput)
    func debugInfo() -> Signal<(String, String), NoError>
    
    func makeIncomingVideoView(completion: @escaping (UIView?) -> Void)
    func makeOutgoingVideoView(completion: @escaping (UIView?) -> Void)
}

public protocol PresentationCallManager: class {
    var currentCallSignal: Signal<PresentationCall?, NoError> { get }
    
    func requestCall(account: Account, peerId: PeerId, endCurrentIfAny: Bool) -> RequestCallResult
}
