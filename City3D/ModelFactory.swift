//
//  ModelFactory.swift
//  Ciudad3D
//
//  Created by Dannover A. on 9/06/26.
//

import SwiftUI
import RealityKit

/// Enumeración para los colores predefinidos de los modelos
enum ModelColor: String, CaseIterable, Identifiable {
    case orange = "Naranja"
    case blue = "Azul"
    case green = "Verde"
    case red = "Rojo"
    case purple = "Morado"
    case yellow = "Amarillo"
    
    var id: String { self.rawValue }
    
    #if os(macOS)
    typealias PlatformColor = NSColor
    #else
    typealias PlatformColor = UIColor
    #endif
    
    var platformColor: PlatformColor {
        switch self {
        case .orange: return .orange
        case .blue: return .systemBlue
        case .green: return .systemGreen
        case .red: return .systemRed
        case .purple: return .systemPurple
        case .yellow: return .systemYellow
        }
    }
}

struct ModelFactory {
    
    /// Crea un cubo en el centro de la escena con color y acabado metálico opcional
    static func createCube(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let mesh = MeshResource.generateBox(size: [1.0, 1.0, 1.0], cornerRadius: 0.1)
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0.5, 0) // Alinear base con el suelo (Y=0)
        return entity
    }
    
    /// Crea una esfera
    static func createSphere(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let mesh = MeshResource.generateSphere(radius: 0.5)
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0.5, 0) // Alinear base con el suelo (Y=0)
        return entity
    }
    
    /// Crea un plano
    static func createPlane(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let mesh = MeshResource.generatePlane(width: 1.5, depth: 1.5, cornerRadius: 0.1)
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        // El plano es horizontal por defecto en XZ, no requiere elevación
        entity.position = SIMD3<Float>(0, 0.01, 0)
        return entity
    }
    
    /// Crea un cono
    static func createCone(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let mesh = MeshResource.generateCone(height: 1.0, radius: 0.5)
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0.5, 0) // Alinear base con el suelo (Y=0)
        return entity
    }
    
    /// Crea un cilindro
    static func createCylinder(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let mesh = MeshResource.generateCylinder(height: 1.0, radius: 0.5)
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0.5, 0) // Alinear base con el suelo (Y=0)
        return entity
    }
    
    /// Crea texto 3D en el origen
    static func createText(text: String, color: ModelColor, isMetallic: Bool) -> ModelEntity {
        // Usamos un tamaño de fuente estándar (12 puntos) para evitar problemas de rasterización de fuentes diminutas en macOS/iOS,
        // y luego aplicamos una escala sobre la entidad para conseguir el tamaño 3D deseado.
        let baseFontSize: CGFloat = 12.0
        let targetHeight: Float = 0.4
        let scaleFactor = targetHeight / Float(baseFontSize) // 0.4 / 12.0 = 0.03333
        
        #if os(macOS)
        let font = NSFont.systemFont(ofSize: baseFontSize, weight: .bold)
        #else
        let font = UIFont.systemFont(ofSize: baseFontSize, weight: .bold)
        #endif
        
        // Marco contenedor proporcional al tamaño de la fuente para centrar el texto
        let containerFrame = CGRect(x: -25, y: -6, width: 50, height: 12)
        
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.15 / scaleFactor, // Escalamos el espesor para obtener 0.15m reales tras aplicar escala
            font: font,
            containerFrame: containerFrame,
            alignment: .center,
            lineBreakMode: .byTruncatingTail
        )
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        
        entity.scale = SIMD3<Float>(repeating: scaleFactor)
        entity.position = SIMD3<Float>(0, 0.2, 0) // Centrar y elevar
        return entity
    }
    
    /// Crea una pirámide usando mallas personalizadas
    static func createPyramid(color: ModelColor, isMetallic: Bool) -> ModelEntity {
        let material = SimpleMaterial(color: color.platformColor, isMetallic: isMetallic)
        let mesh = createPyramidMesh() ?? MeshResource.generateBox(size: [1.0, 1.0, 1.0], cornerRadius: 0.1)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.position = SIMD3<Float>(0, 0, 0) // El origen de la pirámide está en su base (Y=0)
        return entity
    }
    
    /// Crea un árbol detallado (Tronco y Copa)
    static func createTree() -> Entity {
        // Tronco: cilindro de 1.4m de alto y 0.15m de radio
        let trunkMesh = MeshResource.generateCylinder(height: 1.4, radius: 0.15)
        let trunkMaterial = SimpleMaterial(color: .brown, isMetallic: false)
        let trunkEntity = ModelEntity(mesh: trunkMesh, materials: [trunkMaterial])
        trunkEntity.position = SIMD3<Float>(0, 0.7, 0) // Subimos el tronco para que repose sobre Y=0
        
        // Copa de hojas: esfera de 0.6m de radio
        let foliageMesh = MeshResource.generateSphere(radius: 0.6)
        let foliageMaterial = SimpleMaterial(color: .systemGreen, isMetallic: false)
        let foliageEntity = ModelEntity(mesh: foliageMesh, materials: [foliageMaterial])
        foliageEntity.position = SIMD3<Float>(0, 0.7, 0) // Elevación relativa al centro del tronco
        
        trunkEntity.addChild(foliageEntity)
        
        // Creamos una entidad contenedora para rotar todo el conjunto sobre su base (0,0,0)
        let container = Entity()
        container.addChild(trunkEntity)
        return container
    }
    
    /// Crea una Casa (Base, Techo de pirámide, Puerta y Ventanas)
    static func createHouse() -> Entity {
        let container = Entity()
        
        // Paredes base: cubo gris claro
        let wallsMesh = MeshResource.generateBox(size: [1.0, 0.8, 1.0], cornerRadius: 0.05)
        #if os(macOS)
        let wallsMaterial = SimpleMaterial(color: NSColor.lightGray, isMetallic: false)
        let doorMaterial = SimpleMaterial(color: NSColor.brown, isMetallic: false)
        let windowMaterial = SimpleMaterial(color: NSColor.yellow, isMetallic: true)
        #else
        let wallsMaterial = SimpleMaterial(color: UIColor.lightGray, isMetallic: false)
        let doorMaterial = SimpleMaterial(color: UIColor.brown, isMetallic: false)
        let windowMaterial = SimpleMaterial(color: UIColor.yellow, isMetallic: true)
        #endif
        
        let wallsEntity = ModelEntity(mesh: wallsMesh, materials: [wallsMaterial])
        wallsEntity.position = SIMD3<Float>(0, 0.4, 0) // Alinear base a Y=0
        container.addChild(wallsEntity)
        
        // Techo: Pirámide roja colocada encima de las paredes
        let roof = createPyramid(color: .red, isMetallic: false)
        roof.scale = SIMD3<Float>(1.2, 0.6, 1.2) // Un poco más ancho que las paredes
        roof.position = SIMD3<Float>(0, 0.8, 0) // Posicionar sobre las paredes
        container.addChild(roof)
        
        // Puerta: Un pequeño rectángulo café al frente
        let doorMesh = MeshResource.generateBox(size: [0.25, 0.5, 0.02], cornerRadius: 0.01)
        let doorEntity = ModelEntity(mesh: doorMesh, materials: [doorMaterial])
        doorEntity.position = SIMD3<Float>(0, 0.25 - 0.4, 0.51) // Relativo a wallsEntity
        wallsEntity.addChild(doorEntity)
        
        // Ventana izquierda: amarilla brillante/metálica
        let windowMesh = MeshResource.generateBox(size: [0.2, 0.2, 0.02], cornerRadius: 0.01)
        let leftWindow = ModelEntity(mesh: windowMesh, materials: [windowMaterial])
        leftWindow.position = SIMD3<Float>(-0.25, 0.5 - 0.4, 0.51)
        wallsEntity.addChild(leftWindow)
        
        // Ventana derecha
        let rightWindow = ModelEntity(mesh: windowMesh, materials: [windowMaterial])
        rightWindow.position = SIMD3<Float>(0.25, 0.5 - 0.4, 0.51)
        wallsEntity.addChild(rightWindow)
        
        return container
    }
    
    /// Crea un Auto 3D (Chasis, Cabina y Ruedas que giran)
    static func createCar() -> Entity {
        let container = Entity()
        
        // Chasis principal del auto
        let bodyMesh = MeshResource.generateBox(size: [1.3, 0.25, 0.65], cornerRadius: 0.04)
        let bodyMaterial = SimpleMaterial(color: .systemRed, isMetallic: true)
        let bodyEntity = ModelEntity(mesh: bodyMesh, materials: [bodyMaterial])
        bodyEntity.position = SIMD3<Float>(0, 0.22, 0) // Elevado para que las ruedas toquen el suelo
        container.addChild(bodyEntity)
        
        // Cabina
        let cabinMesh = MeshResource.generateBox(size: [0.65, 0.28, 0.55], cornerRadius: 0.04)
        #if os(macOS)
        let cabinMaterial = SimpleMaterial(color: NSColor.darkGray, isMetallic: false)
        let wheelMaterial = SimpleMaterial(color: NSColor.black, isMetallic: false)
        #else
        let cabinMaterial = SimpleMaterial(color: UIColor.darkGray, isMetallic: false)
        let wheelMaterial = SimpleMaterial(color: UIColor.black, isMetallic: false)
        #endif
        let cabinEntity = ModelEntity(mesh: cabinMesh, materials: [cabinMaterial])
        cabinEntity.position = SIMD3<Float>(-0.1, 0.265, 0) // Ligeramente desplazada hacia atrás
        bodyEntity.addChild(cabinEntity)
        
        // Ruedas (Cilindros rotados)
        let wheelMesh = MeshResource.generateCylinder(height: 0.1, radius: 0.13)
        
        let wheelsData: [(Float, Float)] = [
            (0.38, 0.33),   // Delantera izquierda
            (0.38, -0.33),  // Delantera derecha
            (-0.38, 0.33),  // Trasera izquierda
            (-0.38, -0.33)  // Trasera derecha
        ]
        
        for (wX, wZ) in wheelsData {
            let wheel = ModelEntity(mesh: wheelMesh, materials: [wheelMaterial])
            wheel.position = SIMD3<Float>(wX, 0.13, wZ)
            // Rotamos el cilindro 90 grados alrededor del eje X para alinearlo como rueda hacia los lados
            wheel.orientation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(1, 0, 0))
            container.addChild(wheel)
        }
        
        return container
    }
    
    /// Genera la malla de una pirámide de base cuadrada
    private static func createPyramidMesh() -> MeshResource? {
        let vertices: [SIMD3<Float>] = [
            SIMD3<Float>(-0.5, 0.0,  0.5), // 0: Base inferior izquierda
            SIMD3<Float>( 0.5, 0.0,  0.5), // 1: Base inferior derecha
            SIMD3<Float>( 0.5, 0.0, -0.5), // 2: Base superior derecha
            SIMD3<Float>(-0.5, 0.0, -0.5), // 3: Base superior izquierda
            SIMD3<Float>( 0.0, 1.0,  0.0)  // 4: Punta
        ]
        
        let normals: [SIMD3<Float>] = [
            simd_normalize(SIMD3<Float>(-0.5,  0.5,  0.5)),
            simd_normalize(SIMD3<Float>( 0.5,  0.5,  0.5)),
            simd_normalize(SIMD3<Float>( 0.5,  0.5, -0.5)),
            simd_normalize(SIMD3<Float>(-0.5,  0.5, -0.5)),
            SIMD3<Float>(0.0, 1.0, 0.0)
        ]
        
        let indices: [UInt32] = [
            0, 1, 4, // Frente
            1, 2, 4, // Derecha
            2, 3, 4, // Atrás
            3, 0, 4, // Izquierda
            0, 3, 1, // Base Triángulo 1
            1, 3, 2  // Base Triángulo 2
        ]
        
        var descriptor = MeshDescriptor(name: "customPyramid")
        descriptor.positions = MeshBuffer(vertices)
        descriptor.normals = MeshBuffer(normals)
        descriptor.primitives = .triangles(indices)
        
        do {
            return try MeshResource.generate(from: [descriptor])
        } catch {
            print("Error al generar la malla de la pirámide: \(error)")
            return nil
        }
    }
}
