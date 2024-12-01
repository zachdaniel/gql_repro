defmodule AshGraphql.Test.Location do
  @moduledoc false
  use Ash.Resource,
    domain: Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :location
  end

  postgres do
    table "locations"
    repo GqlRepro.Repo
  end

  actions do
    default_accept [:*]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    integer_primary_key :id
    attribute :city, :string, public?: true
  end
end
