defmodule BatchElixir.RestClient.Transactional.Landing do
  @moduledoc """
  Structure for landing object in transactional object
  """
  @derive [Poison.Encoder]
  defmodule Action do
    @derive [Poison.Encoder]
    @moduledoc """
    Structure for action object in landing object
    """
    @type t :: %__MODULE__{
            action: String.t(),
            label: String.t(),
            args: map()
          }
    @enforce_keys [:action, :label]
    defstruct [:action, :label, :args]
  end

  @type t :: %__MODULE__{
          theme: String.t(),
          image: String.t(),
          image_description: String.t(),
          tracking_id: String.t(),
          header: String.t(),
          title: String.t(),
          body: String.t(),
          body: String.t(),
          actions: [Action.t()]
        }
  @enforce_keys [:theme, :actions]
  defstruct [:theme, :image, :image_description, :tracking_id, :header, :title, :body, :actions]
end
