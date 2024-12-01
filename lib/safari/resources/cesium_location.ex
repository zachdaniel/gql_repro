defmodule Safari.Virtual.CesiumLocation do
  use Ash.Resource,
    domain: Safari.Virtual,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :cesium_location
  end

  postgres do
    table "cesium_asset_locations"
    repo GqlRepro.Repo
  end

  code_interface do
    define :by_id, action: :read, get_by: [:id]
    define :create, action: :create
    define :update, action: :update
  end

  actions do
    default_accept :*
    defaults [:read, :update, :create]
  end

  validations do
    present([:heading, :pitch, :roll, :longitude, :latitude, :height])
  end

  attributes do
    integer_primary_key :id, public?: true

    # Orientation
    attribute :heading, :float, public?: true, allow_nil?: false
    attribute :pitch, :float, public?: true, allow_nil?: false
    attribute :roll, :float, public?: true, allow_nil?: false

    # Location
    attribute :longitude, :float, public?: true, allow_nil?: false
    attribute :latitude, :float, public?: true, allow_nil?: false
    attribute :height, :float, public?: true, allow_nil?: false
  end
end
