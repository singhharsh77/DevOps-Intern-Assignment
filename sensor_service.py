import time
import random
from flask import Flask, jsonify
from prometheus_client import Counter, Gauge, Histogram, generate_latest, CollectorRegistry

app = Flask(__name__)

# Create a custom registry to avoid duplicate metric registration
registry = CollectorRegistry()

# Metrics with custom registry
REQUEST_COUNT = Counter(
    "sensor_requests_total", 
    "Total sensor requests", 
    registry=registry
)
CPU_SPIKE = Gauge(
    "sensor_cpu_spike", 
    "Simulated CPU spike state", 
    registry=registry
)
PROCESS_LATENCY = Histogram(
    "sensor_processing_latency_seconds", 
    "Processing time",
    buckets=(0.001, 0.005, 0.01, 0.025, 0.05, 0.1, 0.5, 1.0),
    registry=registry
)

# NEW CUSTOM METRIC: Track scrape failures
SCRAPE_ERRORS = Counter(
    "sensor_scrape_errors_total",
    "Total number of failed scrape attempts",
    registry=registry
)

# NEW CUSTOM METRIC: Memory usage gauge
MEMORY_USAGE = Gauge(
    "sensor_memory_bytes",
    "Approximate memory usage in bytes",
    registry=registry
)

# NEW CUSTOM METRIC: Request processing queue depth
QUEUE_DEPTH = Gauge(
    "sensor_queue_depth",
    "Current processing queue depth",
    registry=registry
)

@app.route("/metrics")
def metrics():
    start = time.time()
    
    try:
        # Removed the wasteful CPU-burning loop
        # Removed the memory-wasting temp_data allocation
        
        # Simulate realistic sensor metrics without waste
        processing_time = time.time() - start
        PROCESS_LATENCY.observe(processing_time)
        
        # Simulate CPU spike (0 or 1)
        CPU_SPIKE.set(random.randint(0, 1))
        
        # Track queue depth (simulated)
        QUEUE_DEPTH.set(random.randint(0, 5))
        
        # Estimate memory usage (in bytes) - simulated for demonstration
        MEMORY_USAGE.set(random.randint(10_000_000, 15_000_000))
        
        REQUEST_COUNT.inc()
        
        return generate_latest(registry)
    
    except Exception as e:
        SCRAPE_ERRORS.inc()
        return f"Error: {str(e)}", 500

@app.route("/sensor")
def sensor():
    # Return lightweight data instead of 5MB blob
    # Simulate realistic sensor data
    return jsonify({
        "status": "ok",
        "temperature": round(random.uniform(20.0, 25.0), 2),
        "humidity": round(random.uniform(40.0, 60.0), 2),
        "timestamp": time.time()
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    # Use single-threaded mode for lower memory footprint
    app.run(host="0.0.0.0", port=8000, threaded=False)