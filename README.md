# Nextbike CGN (NBC)

Nextbike CGN is a Phoenix application that tracks KVB bike-sharing bicycles in Cologne, Germany. The application collects data from the Nextbike API and stores historical location information.

## Features

* Real-time map display of bike locations
* Historical bike position tracking
* Automated data collection every 5 minutes

## Getting Started

### Prerequisites

* Elixir 1.15 or later
* Erlang 25 or later
* PostgreSQL 14 or later
* Node.js 18 or later (for asset compilation)

### Local Development Setup

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Docker Setup

The application can also be run using Docker and Docker Compose:

1. Make sure Docker and Docker Compose are installed on your system
2. Clone the repository
3. Build and start the containers:

```bash
docker-compose up -d
```

The application will be available at [`localhost:4000`](http://localhost:4000).

#### Docker Environment Variables

You can customize the Docker setup using the following environment variables:

* `SECRET_KEY_BASE` - Secret key for Phoenix (auto-generated if not provided)
* `DATABASE_URL` - PostgreSQL connection string
* `BIKE_FETCH_SCHEDULE` - Cron schedule for bike data fetching (default: "*/5 * * * *")
* `NEXTBIKE_CONNECT_TIMEOUT` - API connection timeout in ms (default: 10000)
* `NEXTBIKE_RETRY_COUNT` - Number of API retry attempts (default: 3)

## Development

### Project Structure

The project follows standard Phoenix and Ash Framework conventions:

* `lib/nextbike` - Core application logic and Ash resources
* `lib/nextbike_web` - Web layer (controllers, LiveView, etc.)
* `lib/nextbike/workers` - Background job workers using Oban

### Data Fetching

Bike data is fetched from the Nextbike API using a scheduled Oban job every 5 minutes. You can also trigger a manual fetch in an IEx console:

```elixir
NBC.Workers.BikeFetcher.schedule_fetch()
```

## Learn more

* [Phoenix Framework](https://www.phoenixframework.org/)
* [Ash Framework](https://ash-hq.org/)
* [Oban Documentation](https://hexdocs.pm/oban)
* [Tailwind CSS](https://tailwindcss.com)
* [daisyUI](https://daisyui.com)
