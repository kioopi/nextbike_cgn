import maplibregl from "maplibre-gl";

const BikeMap = {
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
      // Add popup for bike information
      this.map.on("click", "bikes-layer", (e) => {
        const coordinates = e.features[0].geometry.coordinates.slice();
        const properties = e.features[0].properties;

        // Create popup content
        const popupContent = `
          <div>
            <strong>Bike #${properties.number}</strong><br>
            ${properties.place_name ? `Location: ${properties.place_name}<br>` : ""}
            ${properties.place_number ? `Place #: ${properties.place_number}` : ""}
          </div>
        `;

        // Create and display the popup
        new maplibregl.Popup()
          .setLngLat(coordinates)
          .setHTML(popupContent)
          .addTo(this.map);
      });

      // Change cursor to pointer when hovering over a bike
      this.map.on("mouseenter", "bikes-layer", () => {
        this.map.getCanvas().style.cursor = "pointer";
      });

      // Change cursor back when leaving a bike
      this.map.on("mouseleave", "bikes-layer", () => {
        this.map.getCanvas().style.cursor = "";
      });
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

export default BikeMap;
