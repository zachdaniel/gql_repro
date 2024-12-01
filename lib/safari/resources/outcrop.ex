defmodule Safari.Outcrop.Outcrop do
  use Ash.Resource,
    domain: Safari.Outcrop,
    data_layer: AshPostgres.DataLayer

  alias Safari.Virtual.VirtualOutcropModel

  postgres do
    table "outcrop"
    repo GqlRepro.Repo
  end

  actions do
    default_accept :*
    defaults [:create, :update, :read, :destroy]
  end

  attributes do
    integer_primary_key :id
  end

  relationships do
    has_many :virtual_outcrops, VirtualOutcropModel, domain: Safari.Virtual
  end

  # If using policies, add the following bypass:
  # policies do
  #   bypass AshAuthentication.Checks.AshAuthenticationInteraction do
  #     authorize_if always()
  #   end
  # end
end
