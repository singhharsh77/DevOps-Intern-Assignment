# Useing Alpine-based PYTHON for smaller image size
FROM python:3.10-alpine

# install only needful dependencies
RUN pip install --no-cache-dir flask==2.3.0 prometheus_client==0.17.0

# copying the service file
COPY sensor_service.py /sensor_service.py

# Seting up the environment variables for optimization
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production

# Run as non-root user for security
RUN adduser -D sensoruser
USER sensoruser

# Expose the service port
EXPOSE 8000

# Run the app
CMD ["python", "sensor_service.py"]