"use client";

import { FormEvent, useState } from "react";
import Link from "next/link";

export default function InscricaoPage() {
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setSubmitted(true);
  }

  if (submitted) {
    return (
      <main className="form-page">
        <Link href="/" className="brand"><span className="brand-mark">☀</span> Eclipse 2026</Link>
        <div className="form-card" style={{ marginTop: 32 }}>
          <div className="eyebrow">Inscrição recebida</div>
          <h1 style={{ fontSize: 48 }}>Está feito. ✨</h1>
          <p className="lead">A tua inscrição foi registada. O sistema irá associar-lhe uma autorização única de levantamento e enviar a confirmação por email.</p>
          <div className="actions"><Link href="/" className="btn">Voltar ao início</Link></div>
        </div>
      </main>
    );
  }

  return (
    <main className="form-page">
      <Link href="/" className="brand"><span className="brand-mark">☀</span> Eclipse 2026</Link>
      <div style={{ margin: "48px 0 22px" }}>
        <div className="eyebrow">Inscrição</div>
        <h1 style={{ fontSize: 52, marginTop: 10 }}>Reserva o teu levantamento.</h1>
        <p className="lead">Preenche os teus dados para receberes a confirmação e o QR Code associado à tua inscrição.</p>
      </div>

      <form className="form-card" onSubmit={handleSubmit}>
        <div className="field">
          <label htmlFor="name">Nome completo</label>
          <input id="name" name="name" required placeholder="O teu nome" autoComplete="name" />
        </div>

        <div className="field">
          <label htmlFor="nif">NIF</label>
          <input id="nif" name="nif" required inputMode="numeric" pattern="[0-9]{9}" maxLength={9} placeholder="000000000" autoComplete="off" />
          <div className="helper">O NIF é utilizado para garantir que cada pessoa tem apenas uma inscrição válida na campanha. Não será colocado no QR Code.</div>
        </div>

        <div className="field">
          <label htmlFor="email">Email</label>
          <input id="email" name="email" type="email" required placeholder="nome@exemplo.pt" autoComplete="email" />
          <div className="helper">Será utilizado para enviar a confirmação da inscrição e o QR Code.</div>
        </div>

        <div className="field">
          <label htmlFor="point">Ponto de levantamento</label>
          <select id="point" name="point" defaultValue="" required>
            <option value="" disabled>Seleciona um ponto</option>
            <option>Lisboa — Club da Visão</option>
            <option>Leiria — Club da Visão</option>
            <option>Porto — Club da Visão</option>
          </select>
          <div className="helper">Poderás alterar o ponto mais tarde, desde que o levantamento ainda não tenha sido realizado e exista stock no novo ponto.</div>
        </div>

        <div className="field">
          <label>
            <input type="checkbox" required style={{ width: "auto", marginRight: 8 }} />
            Li e aceito a informação de privacidade aplicável a esta inscrição.
          </label>
        </div>

        <button className="btn" style={{ marginTop: 24, width: "100%" }}>Confirmar inscrição</button>
      </form>
    </main>
  );
}
