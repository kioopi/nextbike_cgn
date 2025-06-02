# Nextbike CGN (NBC)

Nextbike CGN is a Phoenix application that tracks KVB bike-sharing bicycles in Cologne, Germany. The application collects data from the Nextbike API and stores historical location information.

## Features

* Map display of bike locations
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

## Development

### Project Structure

The project follows standard Phoenix and Ash Framework conventions:

* `lib/nextbike` - Core application logic and Ash resources
* `lib/nextbike_web` - Web layer (controllers, LiveView, etc.)

### Data Fetching

Bike data is fetched from the Nextbike API using a scheduled Oban job every 5 minutes. You can also trigger a manual fetch in an IEx console:

```bash
iex -S mix
```

Then run the following command to fetch and store bike data:

```elixir
NBC.Bikes.create_bikes_from_api()
```

## Learn more

* [Phoenix Framework](https://www.phoenixframework.org/)
* [Ash Framework](https://ash-hq.org/)
* [Oban Documentation](https://hexdocs.pm/oban)
* [Tailwind CSS](https://tailwindcss.com)
* [daisyUI](https://daisyui.com)
