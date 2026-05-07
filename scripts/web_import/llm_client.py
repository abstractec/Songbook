import os
from dataclasses import dataclass
from typing import Optional


@dataclass
class LLMConfig:
    provider: str
    model: str
    temperature: float
    ollama_base_url: str


DEFAULT_MODELS = {
    "ollama": "llama3.1:8b",
    "openai": "gpt-4o-mini",
    "gemini": "gemini-1.5-flash",
}


def _require_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        raise ValueError(f"Missing required environment variable: {name}")
    return value


def resolve_config(
    provider: Optional[str],
    model: Optional[str],
    temperature: Optional[float],
    ollama_base_url: Optional[str],
) -> LLMConfig:
    resolved_provider = (provider or os.getenv("SONGBOOK_LLM_PROVIDER") or "ollama").lower()
    resolved_model = model or os.getenv("SONGBOOK_LLM_MODEL") or DEFAULT_MODELS.get(resolved_provider, "")
    resolved_temperature = float(
        temperature
        if temperature is not None
        else os.getenv("SONGBOOK_LLM_TEMPERATURE", "0.0")
    )
    resolved_ollama_base_url = (
        ollama_base_url
        or os.getenv("OLLAMA_BASE_URL")
        or "http://localhost:11434"
    )

    if resolved_provider not in {"ollama", "openai", "gemini"}:
        raise ValueError(
            "Unsupported provider. Expected one of: ollama, openai, gemini"
        )
    if not resolved_model:
        raise ValueError(f"No model configured for provider '{resolved_provider}'")

    return LLMConfig(
        provider=resolved_provider,
        model=resolved_model,
        temperature=resolved_temperature,
        ollama_base_url=resolved_ollama_base_url,
    )


def build_chat_model(config: LLMConfig):
    if config.provider == "ollama":
        try:
            from langchain_ollama import ChatOllama
        except ImportError as exc:
            raise ImportError(
                "Missing dependency 'langchain-ollama'. Install requirements first."
            ) from exc
        return ChatOllama(
            model=config.model,
            temperature=config.temperature,
            base_url=config.ollama_base_url,
        )

    if config.provider == "openai":
        _require_env("OPENAI_API_KEY")
        try:
            from langchain_openai import ChatOpenAI
        except ImportError as exc:
            raise ImportError(
                "Missing dependency 'langchain-openai'. Install requirements first."
            ) from exc
        return ChatOpenAI(model=config.model, temperature=config.temperature)

    if config.provider == "gemini":
        _require_env("GOOGLE_API_KEY")
        try:
            from langchain_google_genai import ChatGoogleGenerativeAI
        except ImportError as exc:
            raise ImportError(
                "Missing dependency 'langchain-google-genai'. Install requirements first."
            ) from exc
        return ChatGoogleGenerativeAI(model=config.model, temperature=config.temperature)

    raise ValueError("Unreachable provider branch")
