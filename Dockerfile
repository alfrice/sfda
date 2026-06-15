FROM python:3.12-slim

ENV POETRY_VERSION=2.3.4 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=true \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    PATH="/sfda/.venv/bin:$PATH"

WORKDIR /sfda

RUN pip install --no-cache-dir poetry==${POETRY_VERSION}

COPY ./ /sfda

RUN poetry install

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/api/health')" || exit 1

CMD ["uvicorn", "sfda.main:app", "--host", "0.0.0.0", "--port", "8000"]
