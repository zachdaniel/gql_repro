defmodule Safari.Virtual.CesiumAssetFileCopy do
  use Ash.Resource,
    domain: Safari.Virtual,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  alias Safari.Virtual.{
    CesiumAsset
  }

  postgres do
    table "cesium_asset_file_copies"
    repo GqlRepro.Repo
  end

  oban do
    domain Safari.Virtual

    triggers do
      trigger :process do
        action :process
        where expr(processed != true and is_nil(error))
        scheduler_cron("*/5 * * * *")
        # on_error :errored

        queue(:cesium_file_copy)
      end
    end
  end

  code_interface do
    define :create, action: :create, args: [:cesium_asset_id]
    define :process, action: :process
  end

  actions do
    read :read do
      primary? true
      pagination keyset?: true
    end

    create :create do
      argument :cesium_asset_id, :integer
      accept [:source_provider, :target_provider, :source_path, :target_path]

      change set_attribute(:cesium_asset_id, arg(:cesium_asset_id))

      change run_oban_trigger(:process), only_when_valid?: true
    end

    update :process do
      require_atomic? false

      change fn changeset, context ->
        changeset
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :source_provider, :atom, constraints: [one_of: [:r2]]
    attribute :target_provider, :atom, constraints: [one_of: [:r2, :cesium_bucket]]
    attribute :processed, :boolean, default: false
    attribute :source_path, :string
    attribute :target_path, :string

    attribute :error, :string
  end

  relationships do
    belongs_to :cesium_asset, CesiumAsset, allow_nil?: false, attribute_type: :integer
  end
end
