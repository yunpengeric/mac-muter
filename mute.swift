import CoreAudio
import Foundation

enum MuteError: LocalizedError {
    case noOutputDevice
    case propertyUnavailable(String)
    case osStatus(String, OSStatus)

    var errorDescription: String? {
        switch self {
        case .noOutputDevice:
            return "No default output audio device was found."
        case .propertyUnavailable(let property):
            return "The current output device does not support \(property)."
        case .osStatus(let action, let status):
            return "\(action) failed with OSStatus \(status)."
        }
    }
}

func defaultOutputDeviceID() throws -> AudioDeviceID {
    var deviceID = AudioDeviceID(kAudioObjectUnknown)
    var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    let status = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &address,
        0,
        nil,
        &propertySize,
        &deviceID
    )

    guard status == noErr else {
        throw MuteError.osStatus("Fetching the default output device", status)
    }

    guard deviceID != kAudioObjectUnknown else {
        throw MuteError.noOutputDevice
    }

    return deviceID
}

func settablePropertyAddress(
    selector: AudioObjectPropertySelector,
    scope: AudioObjectPropertyScope,
    element: AudioObjectPropertyElement = kAudioObjectPropertyElementMain,
    on deviceID: AudioDeviceID
) -> AudioObjectPropertyAddress? {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: scope,
        mElement: element
    )

    guard AudioObjectHasProperty(deviceID, &address) else {
        return nil
    }

    var isSettable = DarwinBoolean(false)
    let status = AudioObjectIsPropertySettable(deviceID, &address, &isSettable)
    guard status == noErr, isSettable.boolValue else {
        return nil
    }

    return address
}

func setMute(on deviceID: AudioDeviceID) throws {
    let muteSelector = kAudioDevicePropertyMute
    let volumeSelector = kAudioDevicePropertyVolumeScalar

    for scope in [kAudioDevicePropertyScopeOutput, kAudioObjectPropertyScopeGlobal] {
        guard var address = settablePropertyAddress(selector: muteSelector, scope: scope, on: deviceID) else {
            continue
        }

        var muted: UInt32 = 1
        let status = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            UInt32(MemoryLayout.size(ofValue: muted)),
            &muted
        )
        guard status == noErr else {
            throw MuteError.osStatus("Muting audio output", status)
        }
        return
    }

    for element in [kAudioObjectPropertyElementMain, AudioObjectPropertyElement(1), AudioObjectPropertyElement(2)] {
        for scope in [kAudioDevicePropertyScopeOutput, kAudioObjectPropertyScopeGlobal] {
            guard var address = settablePropertyAddress(selector: volumeSelector, scope: scope, element: element, on: deviceID) else {
                continue
            }

            var volume: Float32 = 0
            let status = AudioObjectSetPropertyData(
                deviceID,
                &address,
                0,
                nil,
                UInt32(MemoryLayout.size(ofValue: volume)),
                &volume
            )
            guard status == noErr else {
                throw MuteError.osStatus("Setting output volume", status)
            }
        }
    }

    throw MuteError.propertyUnavailable("mute or volume control")
}

do {
    let deviceID = try defaultOutputDeviceID()
    try setMute(on: deviceID)
} catch {
    FileHandle.standardError.write(Data("\(error.localizedDescription)\n".utf8))
    exit(1)
}
