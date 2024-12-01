defmodule Safari.Virtual.CesiumAssetBucketConfig do
  use Ash.Resource,
    data_layer: :embedded

  attributes do
    integer_primary_key :id

    attribute :endpoint, :string, allow_nil?: false
    attribute :access_key, :string, allow_nil?: false
    attribute :secret_access_key, :string, allow_nil?: false
    attribute :session_token, :string, allow_nil?: false
    attribute :bucket, :string, allow_nil?: false
    attribute :prefix, :string, allow_nil?: false
  end

  actions do
    defaults [:read, :update]
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
