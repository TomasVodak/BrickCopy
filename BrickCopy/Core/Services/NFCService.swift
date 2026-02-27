import CoreNFC
import Foundation

// Wraps CoreNFC for two operations:
//   read  — scan a tag and return the profile UUID string it contains
//   write — encode a profile UUID onto a blank (or rewritable) tag
//
// Requirements before this works on a real device:
//   1. Add "Near Field Communication Tag Reading" capability in Xcode
//      (Signing & Capabilities → + Capability → Near Field Communication Tag Reading)
//   2. Add NFCReaderUsageDescription to Info.plist (already done via build settings)
//   3. A physical iPhone 7+ (NFC is not available on the Simulator)
//
// NFCNDEFReaderSession.readingAvailable is false on the Simulator, so the UI
// should guard on that and hide/disable NFC controls accordingly.

@Observable
class NFCService: NSObject {

    var isScanning = false
    var errorMessage: String?

    private var readerSession: NFCNDEFReaderSession?
    private var pendingWrite: String?         // profile UUID to write; nil = read mode
    private var onRead: ((String) -> Void)?
    private var onWriteSuccess: (() -> Void)?

    static var isAvailable: Bool {
        NFCNDEFReaderSession.readingAvailable
    }

    // MARK: - Public API

    /// Scan a tag and call `completion` with the profile UUID string it contains.
    func read(completion: @escaping (String) -> Void) {
        guard NFCService.isAvailable else { return }
        pendingWrite = nil
        onRead = completion
        beginSession(alert: "Hold your iPhone near the NFC tag")
    }

    /// Write `profileId` (a UUID string) onto the next scanned tag.
    func write(profileId: String, onSuccess: @escaping () -> Void) {
        guard NFCService.isAvailable else { return }
        pendingWrite = profileId
        onWriteSuccess = onSuccess
        beginSession(alert: "Hold near the NFC tag to link it to this profile")
    }

    // MARK: - Private

    private func beginSession(alert: String) {
        isScanning = true
        errorMessage = nil
        readerSession = NFCNDEFReaderSession(delegate: self, queue: .main, invalidateAfterFirstRead: false)
        readerSession?.alertMessage = alert
        readerSession?.begin()
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCService: NFCNDEFReaderSessionDelegate {

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag detected.")
            return
        }

        session.connect(to: tag) { [weak self] error in
            guard let self else { return }
            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }

            if let profileId = self.pendingWrite {
                self.writePayload(profileId, to: tag, session: session)
            } else {
                self.readPayload(from: tag, session: session)
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        isScanning = false
        let nfcError = error as? NFCReaderError
        // Code 200 = user cancelled — not a real error worth surfacing
        if nfcError?.code != .readerSessionInvalidationErrorUserCanceled {
            errorMessage = error.localizedDescription
        }
    }

    // Unused but required by protocol when implementing didDetect tags:
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    // MARK: - Read

    private func readPayload(from tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        tag.readNDEF { [weak self] message, error in
            guard let self else { return }
            defer { self.isScanning = false }

            guard let record = message?.records.first, error == nil else {
                session.invalidate(errorMessage: "This tag has no BrickCopy data. Link it to a profile first.")
                return
            }

            // NDEF Text record layout: 1 status byte + N lang bytes + UTF-8 text
            let payload = record.payload
            guard payload.count > 1 else {
                session.invalidate(errorMessage: "Unreadable tag.")
                return
            }
            let langLength = Int(payload[0] & 0x3F)
            let textData = payload.dropFirst(1 + langLength)
            guard let profileId = String(data: textData, encoding: .utf8) else {
                session.invalidate(errorMessage: "Could not decode tag.")
                return
            }

            session.alertMessage = "Profile activated!"
            session.invalidate()
            self.onRead?(profileId)
        }
    }

    // MARK: - Write

    private func writePayload(_ profileId: String, to tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: profileId,
            locale: Locale(identifier: "en")
        ) else {
            session.invalidate(errorMessage: "Failed to build NFC payload.")
            return
        }

        let message = NFCNDEFMessage(records: [payload])
        tag.writeNDEF(message) { [weak self] error in
            guard let self else { return }
            self.isScanning = false

            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            session.alertMessage = "Tag linked successfully!"
            session.invalidate()
            self.onWriteSuccess?()
        }
    }
}
