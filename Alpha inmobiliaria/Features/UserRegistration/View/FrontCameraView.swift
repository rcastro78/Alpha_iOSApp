//
//  FrontCameraView.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 25/4/26.
//


import SwiftUI
import AVFoundation
import Foundation
import Combine

// MARK: - FrontCameraView

struct FrontCameraView: View {
    var onCapture: (UIImage) -> Void
    var onCancel: () -> Void

    @StateObject private var camera = CameraViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Preview de la cámara
            CameraPreviewView(session: camera.session)
                .ignoresSafeArea()

            // Overlay con óvalo
            OvalOverlay()

            // Instrucción
            VStack {
                Text("Centra tu rostro en el óvalo")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.top, 72)
                Spacer()
            }

            // Controles inferiores
            VStack {
                Spacer()
                HStack {
                    // Cancelar
                    Button(action: onCancel) {
                        Text("Cancelar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    // Botón captura
                    Button(action: {
                        camera.capturePhoto { image in
                            onCapture(image)
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                            Circle()
                                .stroke(Color.black, lineWidth: 3)
                                .frame(width: 60, height: 60)
                        }
                    }

                    Spacer()
                    // Espacio simétrico al botón cancelar
                    Text("Cancelar").opacity(0)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .onAppear  { camera.startSession() }
        .onDisappear { camera.stopSession() }
    }
}

// MARK: - OvalOverlay

struct OvalOverlay: View {
    var body: some View {
        GeometryReader { geo in
            let cx = geo.size.width  / 2
            let cy = geo.size.height * 0.42
            let rx = geo.size.width  * 0.36
            let ry = geo.size.height * 0.28

            Canvas { ctx, size in
                // Fondo oscuro
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.55)))

                // Recorte del óvalo (blendMode clear)
                let ovalRect = CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2)
                ctx.blendMode = .clear
                ctx.fill(Ellipse().path(in: ovalRect), with: .color(.white))
            }

            // Borde del óvalo
            let ovalRect = CGRect(x: cx - rx, y: cy - ry, width: rx * 2, height: ry * 2)
            Ellipse()
                .stroke(Color.white, lineWidth: 3)
                .frame(width: rx * 2, height: ry * 2)
                .position(x: cx, y: cy)
        }
    }
}

// MARK: - CameraPreviewView (UIViewRepresentable)

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get { previewLayer.session }
        set {
            previewLayer.session = newValue
            previewLayer.videoGravity = .resizeAspectFill
        }
    }
}

// MARK: - CameraViewModel

@MainActor
class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((UIImage) -> Void)?

    override init() {
        super.init()
        setupSession()
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Cámara frontal
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
            let input  = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    func startSession() {
        Task.detached(priority: .userInitiated) { [weak self] in
            self?.session.startRunning()
        }
    }

    func stopSession() {
        Task.detached(priority: .userInitiated) { [weak self] in
            self?.session.stopRunning()
        }
    }

    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    // MARK: - AVCapturePhotoCaptureDelegate

    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard
            error == nil,
            let data  = photo.fileDataRepresentation(),
            let image = UIImage(data: data)
        else { return }

        // Voltear horizontalmente (mirror) — las selfies con cámara frontal quedan espejadas
        let mirrored = UIImage(cgImage: image.cgImage!, scale: image.scale,
                               orientation: .leftMirrored)

        Task { @MainActor [weak self] in
            self?.captureCompletion?(mirrored)
            self?.captureCompletion = nil
        }
    }
}
