"use client"

import { FormEvent, useEffect, useState } from "react"
import Link from "next/link"

interface DistributionPoint {
  id: string
  name: string
  city: string
}

interface RegistrationResult {
  participantCode: string
  token: string
  pointName: string
}

const ERROR_MESSAGES: Record<string, string> = {
  missing_fields: "Preenche todos os campos obrigatórios.",
  invalid_email: "Introduz um endereço de email válido.",
  email_already_registered:
    "Este email já tem uma inscrição registada nesta campanha.",
  invalid_point: "O ponto de levantamento selecionado não está disponível.",
  registration_failed:
    "Ocorreu um erro ao processar a inscrição. Tenta novamente.",
}

export default function InscricaoPage() {
  const [points, setPoints] = useState<DistributionPoint[]>([])
  const [loadingPoints, setLoadingPoints] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [result, setResult] = useState<RegistrationResult | null>(null)

  useEffect(() => {
    fetch("/api/distribution-points")
      .then((r) => r.json())
      .then((data) => setPoints(data.points ?? []))
      .catch(() => setPoints([]))
      .finally(() => setLoadingPoints(false))
  }, [])

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setError(null)
    setSubmitting(true)

    const form = event.currentTarget
    const data = new FormData(form)

    const payload = {
      name: data.get("name") as string,
      email: data.get("email") as string,
      pointId: data.get("point") as string,
    }

    try {
      const response = await fetch("/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      })

      const json = await response.json()

      if (!response.ok) {
        const key = json.error ?? "registration_failed"
        setError(ERROR_MESSAGES[key] ?? ERROR_MESSAGES.registration_failed)
        return
      }

      setResult(json)
    } catch {
      setError(ERROR_MESSAGES.registration_failed)
    } finally {
      setSubmitting(false)
    }
  }

  if (result) {
    const qrData = `ECL:${result.token}`
    const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(qrData)}`

    return (
      <main className="form-page">
        <Link href="/" className="brand">
          <span className="brand-mark">☀</span> Eclipse 2026
        </Link>
        <div className="form-card" style={{ marginTop: 32 }}>
          <div className="eyebrow">Inscrição confirmada</div>
          <h1 style={{ fontSize: 40 }}>Está feito. ✨</h1>
          <p className="lead">
            A tua inscrição foi registada. Vais receber a confirmação e o QR
            Code por email em breve.
          </p>

          <div style={{ margin: "28px 0", textAlign: "center" }}>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={qrUrl}
              alt="QR Code de levantamento"
              width={200}
              height={200}
              style={{ borderRadius: 8, display: "inline-block" }}
            />
          </div>

          <div className="field" style={{ marginBottom: 8 }}>
            <label>Código de inscrição</label>
            <div
              style={{
                fontFamily: "monospace",
                fontSize: 24,
                fontWeight: 700,
                letterSpacing: 2,
                padding: "12px 16px",
                background: "rgba(0,0,0,0.04)",
                borderRadius: 8,
                textAlign: "center",
              }}
            >
              {result.participantCode}
            </div>
          </div>

          <p style={{ fontSize: 14, opacity: 0.6, textAlign: "center", marginTop: 12 }}>
            Ponto de levantamento: <strong>{result.pointName}</strong>
          </p>

          <div className="actions" style={{ marginTop: 28 }}>
            <Link href="/" className="btn">
              Voltar ao início
            </Link>
          </div>
        </div>
      </main>
    )
  }

  return (
    <main className="form-page">
      <Link href="/" className="brand">
        <span className="brand-mark">☀</span> Eclipse 2026
      </Link>
      <div style={{ margin: "48px 0 22px" }}>
        <div className="eyebrow">Inscrição</div>
        <h1 style={{ fontSize: 52, marginTop: 10 }}>
          Reserva o teu levantamento.
        </h1>
        <p className="lead">
          Preenche os teus dados para receberes a confirmação e o QR Code
          associado à tua inscrição.
        </p>
      </div>

      <form className="form-card" onSubmit={handleSubmit}>
        <div className="field">
          <label htmlFor="name">Nome completo</label>
          <input
            id="name"
            name="name"
            required
            placeholder="O teu nome"
            autoComplete="name"
            disabled={submitting}
          />
        </div>

        <div className="field">
          <label htmlFor="email">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            required
            placeholder="nome@exemplo.pt"
            autoComplete="email"
            disabled={submitting}
          />
          <div className="helper">
            Utilizado para enviar a confirmação da inscrição e o QR Code.
            Garante tambem que cada pessoa tem apenas uma inscrição válida
            na campanha.
          </div>
        </div>

        <div className="field">
          <label htmlFor="point">Ponto de levantamento</label>
          <select
            id="point"
            name="point"
            defaultValue=""
            required
            disabled={submitting || loadingPoints}
          >
            <option value="" disabled>
              {loadingPoints ? "A carregar pontos..." : "Seleciona um ponto"}
            </option>
            {points.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
          <div className="helper">
            Poderás alterar o ponto mais tarde, desde que o levantamento
            ainda não tenha sido realizado e exista stock disponivel.
          </div>
        </div>

        <div className="field">
          <label>
            <input
              type="checkbox"
              required
              style={{ width: "auto", marginRight: 8 }}
              disabled={submitting}
            />
            Li e aceito a informação de privacidade aplicável a esta inscrição.
          </label>
        </div>

        {error && (
          <div
            style={{
              background: "rgba(220,38,38,0.08)",
              border: "1px solid rgba(220,38,38,0.2)",
              borderRadius: 8,
              padding: "12px 16px",
              fontSize: 14,
              color: "rgb(185,28,28)",
            }}
          >
            {error}
          </div>
        )}

        <button
          className="btn"
          style={{ marginTop: 24, width: "100%" }}
          disabled={submitting}
        >
          {submitting ? "A processar..." : "Confirmar inscrição"}
        </button>
      </form>
    </main>
  )
}