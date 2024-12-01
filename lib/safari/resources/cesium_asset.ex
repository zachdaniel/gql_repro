defmodule Safari.Virtual.CesiumAsset do
  use Ash.Resource,
    domain: Safari.Virtual,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStateMachine, AshOban, AshGraphql.Resource]

  # authorizers: [Ash.Policy.Authorizer]

  alias Safari.Virtual.{
    CesiumAssetArchiveZipDownload,
    CesiumAssetBucketCredentials,
    CesiumAssetFileCopy,
    CesiumAssetPollChange,
    CesiumAssetGenerateTilesetTokenCalculcation,
    CesiumAssetPathCalculation,
    CesiumAssetStageFilesCalculation,
    CesiumLocation,
    CesiumUtmData,
    VirtualOutcropModel
  }

  graphql do
    type :cesium_asset

    queries do
      get :cesium_asset_get, :read
      list :cesium_asset_list, :read
    end

    mutations do
      create :cesium_asset_create_initial_from_vom, :create_initial_from_vom
      update :cesium_asset_start_upload, :start_upload
      update :cesium_asset_poll_tiling, :poll_tiling
      update :cesium_asset_approve_quality, :approve_quality
      update :cesium_asset_reset_inital_files, :reset_inital_files
      update :cesium_asset_reset_to_initialized, :reset_to_initialized
      update :cesium_asset_set_utm, :set_utm
      update :cesium_asset_place_asset, :place_asset
      update :cesium_asset_save_default_camera, :save_default_camera
      update :cesium_asset_set_clipping, :set_clipping
      update :cesium_asset_mark_as_completed, :mark_as_completed
      action :cesium_asset_initiate_multipart, :initiate_multipart
      action :cesium_asset_complete_multipart, :complete_multipart
      action :cesium_asset_abort_multipart, :abort_multipart
      action :cesium_asset_delete_staged_file, :delete_staged_file
    end
  end

  # CesiumAssetState GraphQL enum defined in:
  # api-nest/src/modules/depositional/cesium/cesiumAsset.entity.ts
  state_machine do
    initial_states([:initialized])
    default_initial_state(:initialized)
    state_attribute(:state)

    transitions do
      transition(:reset_to_initialized, from: [:failed, :quality_assurance], to: :initialized)
      transition(:start_upload, from: :initialized, to: :uploading)
      transition(:poll_tiling, from: :uploading, to: :processing)
      transition(:poll_tiling, from: :processing, to: :archiving)
      transition(:poll_tiling, from: :archiving, to: :downloading)
      transition(:poll_tiling, from: :downloading, to: :quality_assurance)
      transition(:approve_quality, from: :quality_assurance, to: :placeable)
      transition(:mark_as_completed, from: :placeable, to: :complete)
      transition(:*, from: [:uploading, :processing, :archiving], to: :failed)
    end
  end

  # policies do
  #   bypass AshOban.Checks.AshObanInteraction do
  #     authorize_if always()
  #   end

  #   bypass actor_attribute_equals(:is_admin, true) do
  #     authorize_if always()
  #   end

  #   policy always() do
  #     authorize_if action(:upload_multipart_chunk)
  #     forbid_if always()
  #   end
  # end

  oban do
    domain Safari.Virtual

    triggers do
      trigger :poll_uploading do
        action :poll_tiling

        where expr(
                state == :uploading and not exists(cesium_asset_file_copies, processed == false)
              )

        scheduler_cron("*/5 * * * *")
        queue(:cesium_process)
      end

      trigger :poll_processing_at_cesium do
        action :poll_tiling

        where expr(state == :processing and is_nil(error))

        scheduler_cron("*/5 * * * *")
        queue(:cesium_process)
      end

      trigger :poll_archiving_at_cesium do
        action :poll_tiling

        where expr(state == :archiving and is_nil(error))

        scheduler_cron("*/5 * * * *")
        queue(:cesium_process)
      end

      trigger :poll_downloading do
        action :poll_tiling

        where expr(
                state == :downloading and
                  not exists(cesium_asset_archive_zip_downloads, processed == false) and
                  is_nil(error)
              )

        scheduler_cron("*/5 * * * *")
        queue(:cesium_process)
      end
    end
  end

  postgres do
    table "cesium_assets"
    repo GqlRepro.Repo

    references do
      reference :location, name: "fk_location_id_cesium_asset_locations_id"
      reference :default_camera, name: "fk_default_camera_id_cesium_asset_locations_id"
    end
  end

  code_interface do
    define :upload_multipart_chunk,
      action: :upload_multipart_chunk,
      args: [:token, :file_data, :part_number]
  end

  actions do
    defaults [:update]

    read :read do
      primary? true
      pagination keyset?: true
    end

    read :get_by_id do
      get_by :id
    end

    read :get_by_vom_id do
      get_by :virtual_outcrop_model_id
    end

    create :create_initial_from_vom do
      argument :vom_id, :integer, allow_nil?: false
      upsert? true
      upsert_identity :unique_per_vom
      change set_attribute(:virtual_outcrop_model_id, arg(:vom_id))
    end

    action :delete_staged_file do
      argument :id, :integer, allow_nil?: false
      argument :file_name, :string, allow_nil?: false

      run fn input, _context ->
        :ok
      end
    end

    action :initiate_multipart, Safari.Types.CesiumAssetMultipartFile do
      argument :file_name, :string, allow_nil?: false
      argument :content_type, :string, allow_nil?: false, default: "text/plain"
      argument :id, :integer, allow_nil?: false

      run fn input, _context ->
        {:ok, %{upload_path: "/api/v4/cesium_assets/1234/multipart_upload_chunk", token: "1234"}}
      end
    end

    action :upload_multipart_chunk, :map do
      argument :token, :string, allow_nil?: false
      argument :file_data, :binary, allow_nil?: false
      argument :part_number, :integer, allow_nil?: false

      run fn input, _context ->
        {:ok, %{part_number: 1, etag: "1234"}}
      end
    end

    action :complete_multipart, :boolean do
      argument :token, :string, allow_nil?: false
      argument :parts, {:array, :map}, allow_nil?: false

      run fn input, _context ->
        true
      end
    end

    action :abort_multipart, :boolean do
      argument :token, :string, allow_nil?: false

      run fn input, _context ->
        true
      end
    end

    update :start_upload do
      require_atomic? false

      validate attribute_equals(:state, :initialized)

      change fn %{data: cesium_asset} = changeset, _context ->
               changeset
             end,
             only_when_valid?: true

      change fn changeset, _context ->
               changeset
             end,
             only_when_valid?: true

      change fn %{data: cesium_asset} = changeset, _context ->
               changeset
             end,
             only_when_valid?: true

      change fn %{context: %{file_list: file_list}} = changeset, context ->
               changeset
             end,
             only_when_valid?: true

      change transition_state(:uploading), only_when_valid?: true

      change fn changeset, contexts ->
               changeset
             end,
             only_when_valid?: true
    end

    update :poll_tiling do
      require_atomic? false
      change CesiumAssetPollChange
    end

    update :approve_quality do
      validate attribute_equals(:state, :quality_assurance)
      change transition_state(:placeable)
      change set_attribute(:approved, true)
    end

    update :reset_inital_files do
      require_atomic? false

      validate attribute_equals(:state, :initialized)

      change fn changeset, _context ->
               changeset
             end,
             only_when_valid?: true
    end

    update :reset_to_initialized do
      require_atomic? false
      # Clean related resources
      change fn changeset, _context ->
        changeset
      end

      change transition_state(:initialized),
        only_when_valid?: true

      change set_attribute(:error, nil),
        only_when_valid?: true
    end

    update :set_utm do
      require_atomic? false

      accept [
        :utm_data
      ]

      require_attributes [
        :utm_data
      ]

      change fn changeset = %{data: ca}, _context ->
               changeset
             end,
             only_when_valid?: true
    end

    update :place_asset do
      require_atomic? false
      argument :location, :map, allow_nil?: false

      change fn changeset = %{data: ca, arguments: %{location: location}}, _context ->
        changeset
      end
    end

    update :save_default_camera do
      description "Saves default camera position for when Cesium Asset loads on a globe."
      require_atomic? false
      argument :default_camera, :map, allow_nil?: false

      change fn changeset = %{data: ca, arguments: %{default_camera: default_camera}}, _context ->
        changeset
      end
    end

    update :set_clipping do
      description "Saves is_clipping for cesium asset"

      accept [
        :is_clipping
      ]

      require_attributes [
        :is_clipping
      ]
    end

    update :mark_as_completed do
      description "Marks Cesium Asset as completed, requires `location`and `default_camera` attributes to be set beforehand."

      validate attribute_equals(:state, :placeable)
      validate attribute_does_not_equal(:location, nil)
      validate attribute_does_not_equal(:default_camera, nil)
      change transition_state(:complete), only_when_valid?: true
    end
  end

  attributes do
    integer_primary_key :id

    attribute :state, Safari.Types.CesiumAssetState,
      allow_nil?: false,
      default: :initialized,
      public?: true

    attribute :cesium_asset_id, :integer, public?: true
    attribute :cesium_bucket_credentials, CesiumAssetBucketCredentials
    attribute :cesium_upload_callback_url, :string
    attribute :cesium_progress, :integer, public?: true
    attribute :cesium_archive_id, :integer
    attribute :cesium_archive_byte_size, :integer

    # Placement data
    attribute :utm_data, CesiumUtmData, public?: true
    attribute :tileset_path, :string, public?: true
    attribute :approved, :boolean, default: false, public?: true
    attribute :is_clipping, :boolean, default: false, public?: true

    attribute :error, :string, public?: true
  end

  relationships do
    belongs_to :virtual_outcrop_model, VirtualOutcropModel,
      public?: true,
      attribute_type: :integer

    has_many :cesium_asset_file_copies, CesiumAssetFileCopy
    has_many :cesium_asset_archive_zip_downloads, CesiumAssetArchiveZipDownload

    belongs_to :location, CesiumLocation,
      public?: true,
      allow_nil?: true,
      attribute_type: :integer

    belongs_to :default_camera, CesiumLocation,
      public?: true,
      allow_nil?: true,
      attribute_type: :integer
  end

  calculations do
    calculate :staged_files, {:array, :string}, CesiumAssetStageFilesCalculation, public?: true

    calculate :tileset_token,
              Safari.Types.TilesetToken,
              CesiumAssetGenerateTilesetTokenCalculcation,
              public?: true

    calculate :tileset_url_local, :string, {CesiumAssetPathCalculation, type: :local},
      public?: true

    calculate :tileset_url, :string, {CesiumAssetPathCalculation, type: :tileset_hosted},
      public?: true

    calculate :tileset_url_embedded,
              :string,
              {CesiumAssetPathCalculation, type: :tileset_embedded},
              public?: true
  end

  aggregates do
    count :cesium_upload_total, :cesium_asset_file_copies do
      filter target_provider: :cesium_bucket
      public? true
    end

    count :cesium_upload_todo, :cesium_asset_file_copies do
      filter target_provider: :cesium_bucket, processed: false
      public? true
    end

    count :cesium_download_total, :cesium_asset_archive_zip_downloads, public?: true

    count :cesium_download_todo, :cesium_asset_archive_zip_downloads do
      filter processed: false
      public? true
    end
  end

  identities do
    identity :unique_per_vom, [:virtual_outcrop_model_id]
  end

  def staging_prefix(id) do
    "staging/cesium_assets/#{id}/"
  end

  def original_prefix(id) do
    "cesium_assets/#{id}/source/"
  end

  def tileset_prefix(id) do
    "cesium_assets/#{id}/tileset/"
  end
end
