defmodule Safari.Virtual.CesiumAssetBucketCredentials do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    integer_primary_key :id

    attribute :access_key_id, :string, allow_nil?: false
    attribute :bucket, :string, allow_nil?: false
    attribute :endpoint, :string, allow_nil?: false
    attribute :prefix, :string, allow_nil?: false
    attribute :secret_access_key, :string, allow_nil?: false
    attribute :session_token, :string, allow_nil?: false
  end

  actions do
    default_accept [
      :access_key_id,
      :bucket,
      :endpoint,
      :prefix,
      :secret_access_key,
      :session_token
    ]

    defaults [:read, :create, :update, :destroy]
  end
end
