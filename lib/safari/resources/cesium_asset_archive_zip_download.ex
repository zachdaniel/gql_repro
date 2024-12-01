defmodule Safari.Virtual.CesiumAssetArchiveZipDownload do
  use Ash.Resource,
    domain: Safari.Virtual,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  alias Safari.Virtual.{
    CesiumAsset
  }

  postgres do
    table "cesium_asset_archive_zip_downloads"
    repo GqlRepro.Repo
  end

  oban do
    domain Safari.Virtual

    triggers do
      trigger :process do
        action :process

        where expr(processed == false and is_nil(error))

        scheduler_cron("*/5 * * * *")
        queue(:cesium_file_download)
      end
    end
  end

  code_interface do
    define :process, action: :process
  end

  actions do
    read :read do
      primary? true
      pagination keyset?: true
    end

    update :process do
      require_atomic? false

      change fn changeset, _context ->
        changeset
      end
    end
  end

  attributes do
    integer_primary_key :id

    attribute :processed, :boolean, default: false
    attribute :target_path, :string, allow_nil?: false

    attribute :file_name, :string, allow_nil?: false
    attribute :compression_method, :integer, allow_nil?: false
    attribute :local_header_offset, :integer, allow_nil?: false
    attribute :compressed_size, :integer, allow_nil?: false
    attribute :crc, :integer, allow_nil?: false
    attribute :uncompressed_size, :integer, allow_nil?: false
    attribute :bit_flag, :integer, allow_nil?: false
    attribute :last_modified_datetime, :naive_datetime, allow_nil?: false

    attribute :cesium_api_asset_id, :integer, allow_nil?: false
    attribute :archive_id, :integer, allow_nil?: false
    attribute :archive_size, :integer, allow_nil?: false

    attribute :error, :string
  end

  relationships do
    belongs_to :cesium_asset, CesiumAsset, allow_nil?: false, attribute_type: :integer
  end
end
