import RealityKit
import SwiftUI
import UIKit

/// The one custom surface: a RealityKit particle field behind the bento.
/// Every other screen stays stock SwiftUI.
struct ParticleField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            DesignTokens.accent
                .opacity(0.14)
                .accessibilityHidden(true)
                .allowsHitTesting(false)
        } else if #available(iOS 18.0, *) {
            CoolingParticles()
        } else {
            LegacyCoolingField()
        }
    }
}

@available(iOS 18.0, *)
private struct CoolingParticles: View {
    var body: some View {
        RealityView { content in
            let host = Entity()
            host.name = "CoolingField"
            host.components.set(Self.emitter())
            host.position = [0, 0, -0.4]
            content.add(host)
        }
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private static func emitter() -> ParticleEmitterComponent {
        var field = ParticleEmitterComponent()
        field.emitterShape = .box
        field.emitterShapeSize = [1.2, 1.6, 0.05]
        field.mainEmitter.birthRate = 18
        field.mainEmitter.lifeSpan = 4
        field.mainEmitter.size = 0.012
        field.mainEmitter.spreadingAngle = .pi / 8
        field.mainEmitter.color = .constant(.single(UIColor(DesignTokens.accent)))
        return field
    }
}

/// iOS 17 still draws the field with RealityKit. Particles arrive with iOS 18.
private struct LegacyCoolingField: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        let host = Entity()
        host.name = "CoolingField"
        let mesh = MeshResource.generateSphere(radius: 0.04)
        var material = UnlitMaterial()
        material.color = .init(tint: UIColor(DesignTokens.accent).withAlphaComponent(0.35))
        host.components.set(ModelComponent(mesh: mesh, materials: [material]))
        host.position = [0, 0, -0.4]
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(host)
        view.scene.addAnchor(anchor)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
