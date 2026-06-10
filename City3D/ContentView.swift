//
//  ContentView.swift
//  City3D
//
//  Created by Dannover Arroyave M. on 9/06/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    
    // Configuración del visualizador
    @State private var selectedModel: ModelType = .tree
    @State private var cameraPreset: CameraPreset = .isometric
    @State private var selectedColor: ModelColor = .orange
    @State private var isMetallic: Bool = false
    @State private var isRotating: Bool = true
    @State private var showGrid: Bool = true
    @State private var inputText: String = "City3D"
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Escena 3D principal
            RealityView { content in
                // Establecer cámara virtual
                content.camera = .virtual
                
                // Configurar y añadir la cámara inicial
                let camera = configureCamera()
                content.add(camera)
                
                // Contenedor para el modelo activo
                let modelAnchor = Entity()
                modelAnchor.name = "modelAnchor"
                content.add(modelAnchor)
                
                // Contenedor para la cuadrícula del suelo
                let gridAnchor = Entity()
                gridAnchor.name = "gridAnchor"
                content.add(gridAnchor)
                
            } update: { content in
                // 1. Actualizar posición de la cámara según el preset
                if let camera = content.entities.first(where: { $0 is PerspectiveCamera }) as? PerspectiveCamera {
                    updateCamera(camera)
                }
                
                // 2. Actualizar visibilidad de la cuadrícula
                if let gridAnchor = content.entities.first(where: { $0.name == "gridAnchor" }) {
                    gridAnchor.children.removeAll()
                    if showGrid {
                        gridAnchor.addChild(createSceneGrid())
                    }
                }
                
                // 3. Actualizar el modelo activo si es necesario
                if let modelAnchor = content.entities.first(where: { $0.name.hasPrefix("modelAnchor") }) {
                    let currentModelId = "modelAnchor:\(selectedModel.rawValue):\(selectedColor.rawValue):\(isMetallic):\(inputText)"
                    
                    if modelAnchor.name != currentModelId {
                        modelAnchor.children.removeAll()
                        
                        let model: Entity
                        switch selectedModel {
                        case .tree:
                            model = ModelFactory.createTree()
                        case .house:
                            model = ModelFactory.createHouse()
                        case .car:
                            model = ModelFactory.createCar()
                        case .cube:
                            model = ModelFactory.createCube(color: selectedColor, isMetallic: isMetallic)
                        case .sphere:
                            model = ModelFactory.createSphere(color: selectedColor, isMetallic: isMetallic)
                        case .cone:
                            model = ModelFactory.createCone(color: selectedColor, isMetallic: isMetallic)
                        case .cylinder:
                            model = ModelFactory.createCylinder(color: selectedColor, isMetallic: isMetallic)
                        case .pyramid:
                            model = ModelFactory.createPyramid(color: selectedColor, isMetallic: isMetallic)
                        case .text:
                            model = ModelFactory.createText(text: inputText.isEmpty ? "City3D" : inputText, color: selectedColor, isMetallic: isMetallic)
                        }
                        
                        modelAnchor.addChild(model)
                        modelAnchor.name = currentModelId
                    }
                    
                    // Manejar la animación de rotación
                    if let model = modelAnchor.children.first {
                        if isRotating {
                            if model.name != "rotating" {
                                model.stopAllAnimations()
                                let rotation = Transform(rotation: simd_quatf(angle: .pi * 2, axis: [0, 1, 0]))
                                if let animation = try? AnimationResource.generate(with: FromToByAnimation(
                                    to: rotation,
                                    duration: 8.0,
                                    bindTarget: .transform,
                                    repeatMode: .repeat
                                )) {
                                    model.playAnimation(animation)
                                    model.name = "rotating"
                                }
                            }
                        } else {
                            if model.name != "static" {
                                model.stopAllAnimations()
                                model.name = "static"
                            }
                        }
                    }
                }
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            
            // Panel de Control Flotante (Glassmorphism)
            controlPanel
        }
    }
    
    // MARK: - Componentes de Interfaz
    
    private var controlPanel: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 16) {
                // Cabecera y Presets de Cámara
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("City3D Studio")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("Visualizador interactivo de elementos")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Botones de presets de cámara
                    HStack(spacing: 8) {
                        ForEach(CameraPreset.allCases) { preset in
                            Button(action: {
                                withAnimation {
                                    cameraPreset = preset
                                }
                            }) {
                                Image(systemName: preset.iconName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(cameraPreset == preset ? .black : .white)
                                    .padding(10)
                                    .background(cameraPreset == preset ? Color.white : Color.white.opacity(0.15))
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .background(Color.white.opacity(0.15))
                
                // Selector de Modelos
                VStack(alignment: .leading, spacing: 8) {
                    Text("MODELOS 3D")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ModelType.allCases) { model in
                                Button(action: {
                                    selectedModel = model
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: model.iconName)
                                            .font(.system(size: 18))
                                            .foregroundColor(selectedModel == model ? .orange : .white)
                                        
                                        Text(model.rawValue)
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 72, height: 72)
                                    .background(selectedModel == model ? Color.orange.opacity(0.15) : Color.white.opacity(0.06))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedModel == model ? Color.orange : Color.clear, lineWidth: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Opciones contextuales del modelo
                VStack(spacing: 12) {
                    // Entrada de texto (solo si el modelo activo es Texto)
                    if selectedModel == .text {
                        HStack {
                            Text("Texto:")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .frame(width: 50, alignment: .leading)
                            
                            TextField("Escribe texto 3D...", text: $inputText)
                                .textFieldStyle(.plain)
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal)
                    }
                    
                    // Configuración de materiales (solo para primitivos geométricos y texto)
                    if selectedModel.isPrimitive {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("COLOR DEL MODELO")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 8) {
                                    ForEach(ModelColor.allCases) { modelColor in
                                        Button(action: {
                                            selectedColor = modelColor
                                        }) {
                                            Circle()
                                                .fill(Color.fromPlatformColor(modelColor.platformColor))
                                                .frame(width: 22, height: 22)
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color.white, lineWidth: selectedColor == modelColor ? 2 : 0)
                                                )
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Acabado metálico
                            Button(action: {
                                isMetallic.toggle()
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isMetallic ? "sparkles" : "circle.dashed")
                                        .font(.system(size: 12))
                                    Text("Metálico")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(isMetallic ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(isMetallic ? Color.orange : Color.white.opacity(0.15))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .background(Color.white.opacity(0.1))
                    
                    // Opciones globales de la escena (Rotación y Cuadrícula)
                    HStack(spacing: 20) {
                        Toggle(isOn: $isRotating) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Rotar Modelo")
                            }
                            .font(.footnote)
                            .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                        
                        Spacer()
                        
                        Toggle(isOn: $showGrid) {
                            HStack(spacing: 6) {
                                Image(systemName: "grid")
                                Text("Mostrar Guía")
                            }
                            .font(.footnote)
                            .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .orange))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 20)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .padding()
        }
    }
    
    // MARK: - Funciones de Configuración de la Escena
    
    private func configureCamera() -> PerspectiveCamera {
        let camera = PerspectiveCamera()
        camera.camera.fieldOfViewInDegrees = 10
        updateCamera(camera)
        return camera
    }
    
    private func updateCamera(_ camera: PerspectiveCamera) {
        let targetPosition: SIMD3<Float>
        switch cameraPreset {
        case .isometric:
            targetPosition = SIMD3<Float>(20.0, 20.0, 20.0)
        case .top:
            targetPosition = SIMD3<Float>(0.01, 28.0, 0.01) // Evitar bloqueo de cardán en 0, 28, 0
        case .front:
            targetPosition = SIMD3<Float>(0.0, 5.0, 25.0)
        }
        
        camera.position = targetPosition
        camera.look(
            at: SIMD3<Float>(0, 0.4, 0), // Apuntar al centro aproximado del modelo
            from: targetPosition,
            relativeTo: nil
        )
    }
    
    /// Genera una cuadrícula tridimensional usando cajas delgadas
    private func createSceneGrid() -> Entity {
        let gridContainer = Entity()
        
        #if os(macOS)
        let lineMaterial = SimpleMaterial(color: NSColor.white.withAlphaComponent(0.15), isMetallic: false)
        #else
        let lineMaterial = SimpleMaterial(color: UIColor.white.withAlphaComponent(0.15), isMetallic: false)
        #endif
        
        let thickness: Float = 0.005
        let length: Float = 4.0
        let lineMesh = MeshResource.generateBox(size: [length, thickness, thickness], cornerRadius: 0)
        
        // Líneas paralelas a Z (separadas en X)
        for i in -2...2 {
            let x = Float(i) * 0.8
            let line = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            line.position = SIMD3<Float>(0, 0, x)
            gridContainer.addChild(line)
        }
        
        // Líneas paralelas a X (separadas en Z)
        for i in -2...2 {
            let z = Float(i) * 0.8
            let line = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            line.position = SIMD3<Float>(z, 0, 0)
            line.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 1, 0))
            gridContainer.addChild(line)
        }
        
        return gridContainer
    }
}

// MARK: - Enums y Extensiones de Soporte

enum CameraPreset: String, CaseIterable, Identifiable {
    case isometric = "Isométrica"
    case top = "Superior"
    case front = "Frontal"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .isometric: return "cube"
        case .top: return "arrow.down"
        case .front: return "eye"
        }
    }
}

enum ModelType: String, CaseIterable, Identifiable {
    case tree = "Árbol"
    case house = "Casa"
    case car = "Auto"
    case cube = "Cubo"
    case sphere = "Esfera"
    case cone = "Cono"
    case cylinder = "Cilindro"
    case pyramid = "Pirámide"
    case text = "Texto"
    
    var id: String { self.rawValue }
    
    var iconName: String {
        switch self {
        case .tree: return "leaf"
        case .house: return "house"
        case .car: return "car"
        case .cube: return "cube"
        case .sphere: return "circle"
        case .cone: return "triangle"
        case .cylinder: return "capsule"
        case .pyramid: return "triangle"
        case .text: return "textformat"
        }
    }
    
    var isPrimitive: Bool {
        switch self {
        case .tree, .house, .car:
            return false
        default:
            return true
        }
    }
}

extension Color {
    static func fromPlatformColor(_ platformColor: ModelColor.PlatformColor) -> Color {
        #if os(macOS)
        return Color(nsColor: platformColor)
        #else
        return Color(uiColor: platformColor)
        #endif
    }
}

#Preview {
    ContentView()
}
