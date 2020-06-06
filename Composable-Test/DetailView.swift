//
//  DetailView.swift
//  Composable-Test
//
//  Created by Joshua Homann on 6/6/20.
//  Copyright © 2020 com.josh. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct DetailState: Equatable {
  var name: String
  var message: String?
}

enum DetailAction: Equatable {
  case tap
}

struct DetailEnvironment {}

let detailReducer = Reducer<DetailState, DetailAction, DetailEnvironment> { state, action,environment in
  switch action {
  case .tap:
    state.message = state.message == nil ? "You tapped me" : nil
    return .none
  }
}

struct DetailView: View {
  let store: Store<DetailState, DetailAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Button(action: { viewStore.send(.tap) }) {
        Text(viewStore.name).font(.largeTitle)
      }
      Text(viewStore.message ?? "").font(.largeTitle)
    }
  }
}

