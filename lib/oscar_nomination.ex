defmodule AshGraphql.Test.OscarNomination do
  @moduledoc false
  use Ash.Resource,
    domain: Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :oscar_nomination
  end

  postgres do
    table "oscar_nominations"
    repo GqlRepro.Repo
  end

  actions do
    default_accept [:*]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, public?: true
  end

  relationships do
    belongs_to :movie, AshGraphql.Test.Movie, public?: true, writable?: true
    belongs_to :nomination_location, AshGraphql.Test.Location, public?: true, writable?: true
    belongs_to :celebration_location, AshGraphql.Test.Location, public?: true, writable?: true
  end

  identities do
    identity :unique_movie, [:movie_id]
  end
end