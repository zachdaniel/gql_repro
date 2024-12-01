defmodule Safari.Virtual.VirtualOutcropModel do
  use Ash.Resource,
    domain: Safari.Virtual,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  # authorizers: [Ash.Policy.Authorizer]

  alias Safari.Outcrop.Outcrop
  alias Safari.Virtual.CesiumAsset

  # policies do
  #   bypass actor_attribute_equals(:is_admin, true) do
  #     authorize_if always()
  #   end

  #   policy always() do
  #     forbid_if always()
  #   end
  # end

  graphql do
    type :virtual_outcrop_model

    queries do
      get :virtual_outcrop_model_get, :read
      list :virtual_outcrop_model_list, :read
    end
  end

  postgres do
    table "virtual_outcrop_models"
    repo GqlRepro.Repo
  end

  code_interface do
    define :by_id, action: :read, get_by: [:id]
  end

  actions do
    default_accept :*
    defaults [:create, :update, :read, :destroy]
  end

  attributes do
    integer_primary_key :id, public?: true
    attribute :name, :string, public?: true
  end

  relationships do
    belongs_to :outcrop, Outcrop,
      domain: Safari.Outcrop,
      attribute_type: :integer,
      writable?: true,
      public?: true

    has_one :cesium_asset, CesiumAsset, public?: true
  end
end
