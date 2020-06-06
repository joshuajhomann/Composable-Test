import ComposableArchitecture
import SwiftUI


struct Item: Equatable, Identifiable {
  var name: String
  let id: UUID
}

struct ListState: Equatable {
  var items: IdentifiedArrayOf<Item> = []
  var selection: Identified<Item.ID, DetailState?>?
}

enum ListAction: Equatable {
  case detail(DetailAction)
  case select(id: UUID?)
  case make
}

struct ListEnvironment {
}

let listReducer = Reducer<ListState, ListAction, ListEnvironment>.combine(
  Reducer { state, action, environment in
    struct CancelId: Hashable {}

    switch action {
    case .make:
      state.items = .init(["🦄", "🐼", "🐸", "🐙", "🐳", "🦋"].map{Item(name: $0, id: .init())}, id: \.id)
      return .none

    case .detail:
      return .none

    case let .select(id):
      guard let id = id,
        let item = state.items[id: id] else {
        return.none
      }
      state.selection = Identified(
        DetailState(name: state.items[id: id]?.name ?? ""),
        id: id
      )
      return .none
    }
  },
  detailReducer
    .optional
    .pullback(state: \Identified.value, action: .self, environment: { $0 })
    .optional
    .pullback(
      state: \ListState.selection,
      action: /ListAction.detail,
      environment: { _ in .init() }
    )
)
.debug()


struct ListView: View {
  let store: Store<ListState, ListAction>

  var body: some View {
    NavigationView {
      WithViewStore(self.store) { viewStore in
        List {
          ForEach(viewStore.items) { item in
            NavigationLink(
              destination: IfLetStore(
                self.store.scope(
                  state: \.selection?.value,
                  action: ListAction.detail),
                then: DetailView.init(store:)
              ),
              tag: item.id,
              selection: viewStore.binding(
                get: \.selection?.id,
                send: ListAction.select(id:)
              )
            ) {
              Text(item.name).font(.largeTitle)
            }
          }
        }
        .onAppear(perform: { viewStore.send(.make) })
      }
      .navigationBarTitle("")
      .navigationBarHidden(true)
    }
  }
}
