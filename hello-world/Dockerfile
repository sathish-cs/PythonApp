FROM python:3.9-slim
#  Workdir is the dir where the files will be copied to  
WORKDIR /app
COPY hello-world.py .
# Install Flask
RUN pip install --no-cache-dir flask
# Expose the port the app runs on
EXPOSE 5000
# Run the application
CMD ["python", "hello-world.py"]
