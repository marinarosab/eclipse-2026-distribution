import { NextRequest, NextResponse } from "next/server"
import { randomUUID, createHash } from "crypto"
import { createServiceClient } from "@/lib/supabase-server"

function generateParticipantCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
  let code = "ECL-"
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)]
  }
  return code
}

function generateQrToken(): { raw: string; hash: string } {
  const raw = randomUUID()
  const hash = createHash("sha256").update(raw).digest("hex")
  return { raw, hash }
}

export async function POST(request: NextRequest) {
  let body: Record<string, unknown>
  try {
    body = await request.json()
  } catch {
    return NextResponse.json({ error: "invalid_request" }, { status: 400 })
  }

  const { name, email, pointId } = body as {
    name?: string
    email?: string
    pointId?: string
  }

  if (!name || !email || !pointId) {
    return NextResponse.json({ error: "missing_fields" }, { status: 400 })
  }

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return NextResponse.json({ error: "invalid_email" }, { status: 400 })
  }

  const supabase = createServiceClient()
  const normalizedEmail = String(email).trim().toLowerCase()

  // Verificar email duplicado
  const { data: existing } = await supabase
    .from("participants")
    .select("id")
    .eq("email", normalizedEmail)
    .maybeSingle()

  if (existing) {
    return NextResponse.json({ error: "email_already_registered" }, { status: 409 })
  }

  // Verificar ponto de distribuição
  const { data: point } = await supabase
    .from("distribution_points")
    .select("id, name")
    .eq("id", pointId)
    .eq("status", "active")
    .maybeSingle()

  if (!point) {
    return NextResponse.json({ error: "invalid_point" }, { status: 400 })
  }

  // Gerar código único de participante
  let participantCode = generateParticipantCode()
  for (let i = 0; i < 5; i++) {
    const { data: codeExists } = await supabase
      .from("participants")
      .select("id")
      .eq("participant_code", participantCode)
      .maybeSingle()
    if (!codeExists) break
    participantCode = generateParticipantCode()
  }

  const { raw: rawToken, hash: tokenHash } = generateQrToken()

  // Inserir participante
  const { data: participant, error: participantError } = await supabase
    .from("participants")
    .insert({
      participant_code: participantCode,
      full_name: String(name).trim(),
      email: normalizedEmail,
      distribution_point_id: pointId,
      status: "pending",
    })
    .select("id, participant_code")
    .single()

  if (participantError || !participant) {
    console.error("Participant insert:", participantError)
    return NextResponse.json({ error: "registration_failed" }, { status: 500 })
  }

  // Registar consentimento
  await supabase.from("consents").insert({
    participant_id: participant.id,
    consent_type: "privacy_policy",
    policy_version: "1.0",
    source: "registration",
  })

  // Gerar e guardar token do QR Code
  const expiresAt = new Date()
  expiresAt.setDate(expiresAt.getDate() + 30)

  await supabase.from("qr_tokens").insert({
    participant_id: participant.id,
    token_hash: tokenHash,
    status: "active",
    expires_at: expiresAt.toISOString(),
  })

  // TODO: enviar email com rawToken incorporado no QR Code

  return NextResponse.json({
    success: true,
    participantCode: participant.participant_code,
    token: rawToken,
    pointName: point.name,
  })
}