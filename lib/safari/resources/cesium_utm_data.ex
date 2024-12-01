defmodule Safari.Virtual.CesiumUtmData do
  use Ash.Resource,
    data_layer: :embedded,
    extensions: [AshGraphql.Resource]

  alias Safari.Virtual.CesiumAssetUtmHemisphereType

  attributes do
    integer_primary_key :id, public?: false

    # Orientation
    attribute :utm_eastings, :float, public?: true, constraints: [min: 0], allow_nil?: false
    attribute :utm_northings, :float, public?: true, allow_nil?: false

    attribute :utm_zone, :integer,
      public?: true,
      constraints: [min: 0, max: 64],
      allow_nil?: false

    attribute :utm_hemisphere, CesiumAssetUtmHemisphereType, public?: true, allow_nil?: false
  end

  graphql do
    type :cesium_utm_data
  end

  actions do
    default_accept :*
    defaults [:read, :update, :create]
  end

  validations do
    present([:utm_eastings, :utm_northings, :utm_zone, :utm_hemisphere])
  end
end
