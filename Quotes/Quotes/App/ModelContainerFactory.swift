//
//  ModelContainerFactory.swift
//  Quotes
//
//  Created by Steven Hill on 17/09/2026.
//

import SwiftData

protocol ModelContainerCreating {
    func makeContainer(
        schema: Schema,
        configuration: ModelConfiguration
    ) throws -> ModelContainer
}

struct ModelContainerFactory: ModelContainerCreating {
    func makeContainer(
        schema: Schema,
        configuration: ModelConfiguration
    ) throws -> ModelContainer {
        try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
