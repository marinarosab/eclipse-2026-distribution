import Link from "next/link";

export default function Home() {
  return (
    <main className="shell">
      <header className="topbar">
        <Link href="/" className="brand"><span className="brand-mark">☀</span> Eclipse 2026</Link>
        <nav className="nav"><Link href="#como-funciona">Como funciona</Link><Link href="#seguranca">Segurança</Link><Link href="/inscricao">Fazer inscrição</Link></nav>
      </header>

      <section className="hero">
        <div>
          <div className="eyebrow">Distribuição segura · Portugal</div>
          <h1>O teu lugar para viver o eclipse.</h1>
          <p className="lead">Inscreve-te para levantar os teus óculos de eclipse num ponto de distribuição. Uma experiência simples para ti — e uma operação segura para quem organiza.</p>
          <div className="actions"><Link href="/inscricao" className="btn">Fazer inscrição</Link><a href="#como-funciona" className="btn secondary">Saber mais</a></div>
        </div>
        <div className="eclipse-art" aria-label="Ilustração de um eclipse"><span>Eclipse · 12 agosto 2026</span></div>
      </section>

      <section className="section" id="como-funciona">
        <div className="eyebrow">Uma experiência simples</div>
        <h2 className="section-title">Da inscrição ao levantamento.</h2>
        <p className="section-copy">O sistema trata da complexidade por trás da experiência para que tu só tenhas de fazer o essencial.</p>
        <div className="cards">
          <article className="card"><div className="card-icon">✍️</div><h3>1. Inscreve-te</h3><p>Preenche os teus dados e escolhe o ponto de levantamento disponível mais conveniente.</p></article>
          <article className="card"><div className="card-icon">🎟️</div><h3>2. Recebe o teu QR Code</h3><p>Recebes uma confirmação digital associada à tua inscrição. Não precisas de memorizar códigos.</p></article>
          <article className="card"><div className="card-icon">📷</div><h3>3. Levanta os óculos</h3><p>No ponto escolhido, apresenta o QR Code. A equipa valida a inscrição e regista a entrega.</p></article>
        </div>
      </section>

      <section className="section" id="seguranca">
        <div className="card"><div className="eyebrow">Privacidade e segurança</div><h2 className="section-title">Uma solução pensada para proteger a experiência.</h2><p className="section-copy">O QR Code não expõe os teus dados pessoais. A autorização de levantamento é controlada pelo sistema e, depois de utilizado, o código não pode ser reutilizado para uma segunda entrega.</p></div>
      </section>

      <footer className="footer">Protótipo de produto · Eclipse 2026 Distribution</footer>
    </main>
  );
}
