# To make it go boom:

1. `mix ecto.reset`
2. ```
query {
	virtualOutcropModelGet(id: "1") {
    id
    name
    cesiumAsset {
      virtualOutcropModelId
      id
      approved
      state
      isClipping
      utmData {
        utmZone
      }
      location{
        id
      }

    }
  }
}
```