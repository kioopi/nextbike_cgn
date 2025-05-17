# Nextbike CGN - Developer Guide

## Overview

Nextbike CGN is a Phoenix web application that tracks KVB (Kölner Verkehrs-Betriebe) bike-sharing bikes in Cologne, Germany. The application fetches data from the Nextbike API and stores historical location data in a PostgreSQL database. Built with Ash Framework for the data layer, Phoenix for the web framework, LiveView for reactive UI, and styled with Tailwind CSS and daisyUI.

## Technology Stack

- **Elixir**: Functional programming language built on top of Erlang VM
- **Phoenix Framework**: Web framework for Elixir applications
- **Phoenix LiveView**: Server-side rendering with client-side interactivity
- **Ash Framework**: Domain-driven design framework for Elixir
- **Ash Postgres**: PostgreSQL adapter for Ash Framework
- **Tailwind CSS**: Utility-first CSS framework
- **daisyUI**: Component library for Tailwind CSS
- **MapLibre**: Map visualization library
- **PostgreSQL**: Relational database for persistent storage

## Project Structure

### Key Directories

- `/lib/nextbike`: Core application logic
  - `/bikes`: Bike domain and resource definitions
  - `/nextbike_api.ex`: API integration with Nextbike
  - `/fetcher.ex`: HTTP client for fetching data
- `/lib/nextbike_web`: Web layer
  - `/live`: LiveView components and pages
  - `/components`: Reusable UI components
- `/priv/repo/migrations`: Database migrations
- `/assets`: Frontend assets (JavaScript, CSS)

## Data Model

The application currently has one primary resource:

### Bike

A bike represents a physical KVB rental bike with its current location.

**Fields**:
- `id`: UUID primary key
- `lat`: Float - Latitude coordinate
- `lng`: Float - Longitude coordinate
- `number`: Integer - Bike identification number
- `place_name`: String - Name of the current location/station
- `place_number`: Integer - Unique identifier of the location/station
- `inserted_at`: UTC timestamp
- `updated_at`: UTC timestamp

## Key Components

### Ash Resources

The application uses Ash Framework to define resources and their behavior:

```elixir
# Bike Resource
defmodule NBC.Bikes.Bike do
  use Ash.Resource, otp_app: :nextbike, domain: NBC.Bikes, data_layer: AshPostgres.DataLayer

  # Resource definition with actions, attributes, etc.
end

# Bikes Domain
defmodule NBC.Bikes do
  use Ash.Domain, otp_app: :nextbike

  resources do
    resource NBC.Bikes.Bike
  end
end
```

### Data Fetching

The `NBC.Fetcher` module handles HTTP requests to the Nextbike API:

```elixir
NBC.Fetcher.fetch_xml("https://api.nextbike.net/maps/nextbike-live.xml", city: 14)
```

The `NBC.NextbikeAPI` module parses the XML response and transforms it into structures that can be saved to the database.

### Validations

The application includes custom validations, such as `HasMoved` which ensures bikes are only recorded when their position has changed:

```elixir
defmodule NBC.Bikes.Bike.Validations.HasMoved do
  use Ash.Resource.Validation

  # Validation logic to check if a bike has moved
end
```

### Web Interface

The main interface is a LiveView page that displays:
1. A map with bike locations (using MapLibre)
2. A table listing all bikes with their current positions

## Missing Features (Todo)

### Docker Setup

**Priority: High**
- Create Dockerfile for the application
- Set up docker-compose.yml with PostgreSQL and the application
- Configure environment variables for production deployment

## Planned Features

1. **Bike History Tracking**
   - Create a UI to view historical positions of a specific bike
   - Implement timeline visualization

2. **Location-based Notifications**
   - Allow users to set up notifications when bikes become available at specific locations
   - Implement notification service (email, push, etc.)

3. **Bike Density Analytics**
   - Create graphs showing bike density over time
   - Implement heatmap visualization for popular areas

## Development Workflow

### Setup

1. Clone the repository
2. Install dependencies: `mix deps.get`
3. Setup database: `mix setup`
4. Start server: `mix phx.server` or `iex -S mix phx.server`
5. Visit [`localhost:4000`](http://localhost:4000) in your browser

### Working with Ash

- Use code interfaces on domains to define the contract for calling into Ash resources
- After creating or modifying Ash code, run `mix ash.codegen <short_name>` to generate migrations
- Always call functions on `Ash`, not directly on the domain:
  ```elixir
  # Correct
  Ash.read!(NBC.Bikes.Bike, :list_current)

  # Incorrect (outdated)
  NBC.Bikes.list_current()
  ```

### UI Development

- Use daisyUI components for consistent styling
- Keep core components clean and avoid inline styles
- Use Tailwind classes for styling

## Useful Commands

- `mix ash.codegen <name>`: Generate migrations for Ash resources
- `mix test`: Run tests
- `mix compile`: Compile the application
- `mix phx.server`: Start development server
- `Ash.Info.mermaid_overview(:nextbike)`: Generate a Mermaid diagram of the Ash resources

## Database

The application uses PostgreSQL for persistent storage. Migrations are defined in `/priv/repo/migrations`.

## Testing

Tests are located in the `/test` directory. Run tests with `mix test`.

## Troubleshooting

### Common Issues

1. **Database connection issues**
   - Check that PostgreSQL is running
   - Verify database credentials in config

2. **API integration issues**
   - Verify Nextbike API endpoint availability
   - Check response format from API

## Resources

- [Phoenix Framework Documentation](https://hexdocs.pm/phoenix)
- [Ash Framework Documentation](https://hexdocs.pm/ash)
- [LiveView Documentation](https://hexdocs.pm/phoenix_live_view)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [daisyUI Documentation](https://daisyui.com/docs)
