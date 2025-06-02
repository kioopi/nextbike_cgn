defmodule NBC.Bikes.Bike do
  use Ash.Resource,
    otp_app: :nextbike,
    domain: NBC.Bikes,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban]

  require Logger

  postgres do
    table "bikes"
    repo NBC.Repo
  end

  oban do
    scheduled_actions do
      schedule :create_from_api, "*/5 * * * *" do
        queue :bikes
        worker_module_name NBC.Bikes.Bike.AshOban.ActionWorker.FetchNextbikeApi
      end
    end
  end

  code_interface do
    define :current, action: :current, args: [:number]
    define :create_from_api, action: :create_from_api
    define :history, action: :history, args: [:number]
  end

  actions do
    defaults [:read, create: :*]

    create :create_if_moved do
      description "Creates a bike record only if it has moved"
      accept :*
      validate NBC.Bikes.Bike.Validations.HasMoved
    end

    read :current do
      description "Returns the bike with the given number at its latest position"
      argument :number, :integer, allow_nil?: false
      prepare build(sort: [inserted_at: :desc], limit: 1)
      filter expr(number == ^arg(:number))
      get? true
    end

    read :list_current do
      description "Returns a list of all bikes at their latest positions"
      prepare build(sort: [inserted_at: :desc], distinct: [:number])
    end

    read :history do
      description "Returns the history of a bike with the given number"
      argument :number, :integer, allow_nil?: false
      prepare build(sort: [inserted_at: :desc])
      filter expr(number == ^arg(:number))
    end

    action :create_from_api, :string do
      description "Creates bike records from API data"

      run fn _, _ ->
        case NBC.Fetcher.fetch_xml("https://api.nextbike.net/maps/nextbike-live.xml", city: 14) do
          {:ok, xml} ->
            bike_data = NBC.NextbikeAPI.parse_bikes_from_xml(xml)
            bikes_count = length(bike_data)

            case Ash.bulk_create(
                   bike_data,
                   __MODULE__,
                   :create_if_moved,
                   rollback_on_error?: false,
                   stop_on_error?: false,
                   return_errors?: true
                 ) do
              %Ash.BulkResult{status: :success} = result ->
                Logger.info("Successfully created bikes from API", %{
                  error_count: result.error_count,
                  inserted: bikes_count - result.error_count
                })

                {:ok, "Succesfully created #{bikes_count - result.error_count} bikes from API"}

              %Ash.BulkResult{status: :partial_success} = result ->
                Logger.info("Successfully created bikes from API", %{
                  error_count: result.error_count,
                  inserted: bikes_count - result.error_count
                })

                {:ok, "Succesfully created #{bikes_count - result.error_count} bikes from API"}

              %Ash.BulkResult{status: :error} = result ->
                Logger.error("Failed to create bikes from API", %{
                  error: inspect(result.errors),
                  error_count: result.error_count
                })

                {:error, "Failed to create bikes from API: #{inspect(result.errors)}"}
            end

          {:error, reason} ->
            Logger.error("Failed to fetch data: #{reason}")
            {:error, "Failed to fetch data: #{reason}"}
        end
      end
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :lat, :float, allow_nil?: false, public?: true
    attribute :lng, :float, allow_nil?: false, public?: true
    attribute :number, :integer, allow_nil?: false, public?: true
    attribute :place_name, :string, allow_nil?: true, public?: true
    attribute :place_number, :integer, allow_nil?: true, public?: true
    timestamps()
  end
end
