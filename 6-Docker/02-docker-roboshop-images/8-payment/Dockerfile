# ============================================================
# Stage 1: Build dependencies
# ============================================================

FROM python:3.9.25-alpine3.22 AS builder

WORKDIR /app

COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps \
        gcc \
        musl-dev \
        linux-headers \
        python3-dev \
    && pip install --no-cache-dir \
        --prefix=/install \
        -r requirements.txt


# ============================================================
# Stage 2: Runtime
# ============================================================

FROM python:3.9.25-alpine3.22

WORKDIR /app

EXPOSE 8080

# Create non-root user
RUN addgroup -S roboshop \
    && adduser -S -G roboshop roboshop

# Copy Python dependencies from builder
COPY --from=builder /install /usr/local

# Copy application files
COPY --chown=roboshop:roboshop payment.ini *.py requirements.txt ./

# Run application as non-root user
USER roboshop

CMD ["uwsgi", "--ini", "payment.ini"]


# FROM python:3.9
# WORKDIR /app
# COPY requirements.txt .
# COPY payment.ini .
# COPY *.py .
# RUN pip3 install -r requirements.txt
# EXPOSE 8080
# CMD ["uwsgi", "--ini", "payment.ini"]