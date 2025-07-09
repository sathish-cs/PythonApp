# Python 3.11 slim image
FROM python:3.11-slim
WORKDIR /app
COPY reverse-hello-world.py .
# Install Flask and requests
RUN pip install flask requests
# Expose the port the app runs on
EXPOSE 8000
# Run the application
CMD ["python", "reverse-hello-world.py"]
