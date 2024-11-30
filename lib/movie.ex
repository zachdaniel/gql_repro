defmodule AshGraphql.Test.Movie do
  @moduledoc false

  use Ash.Resource,
    domain: Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  graphql do
    type :movie

    queries do
      get :get_movie, :read
    end
  end

  postgres do
    table "movies"
    repo GqlRepro.Repo
  end

  actions do
    default_accept :*
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string, public?: true
  end

  relationships do
    has_one :oscar_nomination, AshGraphql.Test.OscarNomination, public?: true
  end
end
