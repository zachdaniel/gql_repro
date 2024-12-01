defmodule Safari.Types.TilesetToken do
  @moduledoc false
  use Ash.Type.NewType,
    subtype_of: :map,
    constraints: [
      fields: [
        token: [type: :string, allow_nil?: false],
        expiry_in_seconds: [type: :integer, allow_nil?: false]
      ]
    ]

  def graphql_type(_), do: :cesium_asset_tileset_token
end

defmodule Safari.Types.CesiumAssetMultipartFile do
  @moduledoc false
  use Ash.Type.NewType,
    subtype_of: :map,
    constraints: [
      fields: [
        upload_path: [type: :string, allow_nil?: false],
        token: [type: :string, allow_nil?: false]
      ]
    ]

  def graphql_type(_), do: :cesium_asset_multipart_file
end

defmodule Safari.Types.CesiumAssetState do
  @moduledoc false
  use Ash.Type.Enum,
    values: [
      :archiving,
      :complete,
      :downloading,
      :failed,
      :initialized,
      :placeable,
      :processing,
      :quality_assurance,
      :uploading
    ]

  def graphql_type(_), do: :cesium_asset_state
end

defmodule Safari.Virtual.CesiumAssetUtmHemisphereType do
  use Ash.Type.Enum, values: [:north, :south]

  def graphql_type(_), do: :cesium_asset_utm_hemisphere
end
