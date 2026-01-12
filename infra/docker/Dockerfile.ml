FROM python:3.11-slim
WORKDIR /workspace
RUN pip install --no-cache-dir pillow
COPY ../../ml ./ml
CMD ["python", "-c", "print('ML worker ready')"]
