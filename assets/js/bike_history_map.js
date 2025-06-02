import maplibregl from "maplibre-gl";

const BikeHistoryMap = {
  mounted() {
    // Get the map specification from the data attribute
    const mapSpec = JSON.parse(this.el.dataset.mapSpec);

    // Initialize the map
    this.map = new maplibregl.Map({
      container: this.el.id,
      style: mapSpec,
      attributionControl: true,
    });

    // Add navigation controls
    this.map.addControl(new maplibregl.NavigationControl(), "top-right");

    this.map.on("load", () => {
      // Add popup for start/end points
      this.map.on("click", "start-point", (e) => {
        const coordinates = e.features[0].geometry.coordinates.slice();
        const properties = e.features[0].properties;

        const popupContent = `
          <div class="text-center">
            <div class="badge badge-success mb-2">Start Point</div><br>
            <strong>Time: ${properties.time}</strong>
          </div>
        `;

        new maplibregl.Popup()
          .setLngLat(coordinates)
          .setHTML(popupContent)
          .addTo(this.map);
      });

      this.map.on("click", "end-point", (e) => {
        const coordinates = e.features[0].geometry.coordinates.slice();
        const properties = e.features[0].properties;

        const popupContent = `
          <div class="text-center">
            <div class="badge badge-error mb-2">End Point</div><br>
            <strong>Time: ${properties.time}</strong>
          </div>
        `;

        new maplibregl.Popup()
          .setLngLat(coordinates)
          .setHTML(popupContent)
          .addTo(this.map);
      });

      // Change cursor to pointer when hovering over points
      this.map.on("mouseenter", "start-point", () => {
        this.map.getCanvas().style.cursor = "pointer";
      });

      this.map.on("mouseleave", "start-point", () => {
        this.map.getCanvas().style.cursor = "";
      });

      this.map.on("mouseenter", "end-point", () => {
        this.map.getCanvas().style.cursor = "pointer";
      });

      this.map.on("mouseleave", "end-point", () => {
        this.map.getCanvas().style.cursor = "";
      });

      // Fit map to route bounds
      if (this.map.getSource("route-source")) {
        const routeData = this.map.getSource("route-source")._data;
        if (routeData && routeData.geometry && routeData.geometry.coordinates) {
          const coordinates = routeData.geometry.coordinates;
          const bounds = coordinates.reduce((bounds, coord) => {
            return bounds.extend(coord);
          }, new maplibregl.LngLatBounds(coordinates[0], coordinates[0]));

          this.map.fitBounds(bounds, {
            padding: 50,
            maxZoom: 16
          });
        }
      }
    });

    // Handle window resize events
    window.addEventListener("resize", () => {
      this.map.resize();
    });
  },

  destroyed() {
    // Clean up map resources when the component is destroyed
    if (this.map) {
      this.map.remove();
    }
  },
};

export default BikeHistoryMap;