#!/bin/bash
#
# Generates the landing page index.html
# This keeps GitHub stats at 100% Shell
#

cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>qBittorrent Backup Linux | Backup & Restore Script</title>
  <meta name="description" content="A simple and reliable script to backup and restore your qBittorrent configuration on Linux. Save all settings, statistics, and torrent list.">
  <meta name="keywords" content="qbittorrent, backup, restore, linux, script, bash, torrent, configuration">
  <meta name="author" content="cantalupo555">
  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Cdefs%3E%3ClinearGradient id='g' x1='0%25' y1='0%25' x2='100%25' y2='100%25'%3E%3Cstop offset='0%25' stop-color='%233b82f6'/%3E%3Cstop offset='100%25' stop-color='%2322d3ee'/%3E%3C/linearGradient%3E%3C/defs%3E%3Crect width='100' height='100' rx='20' fill='url(%23g)'/%3E%3Crect x='22' y='35' width='56' height='45' rx='6' fill='none' stroke='white' stroke-width='6'/%3E%3Crect x='30' y='20' width='40' height='25' rx='4' fill='white'/%3E%3Cpath d='M38 28h24M38 36h16' stroke='%233b82f6' stroke-width='4' stroke-linecap='round'/%3E%3C/svg%3E">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-primary: #0f172a;
      --bg-secondary: #1e293b;
      --bg-card: #1e293b;
      --accent-blue: #3b82f6;
      --accent-blue-light: #60a5fa;
      --accent-blue-dark: #2563eb;
      --accent-cyan: #22d3ee;
      --accent-orange: #f97316;
      --text-primary: #f1f5f9;
      --text-secondary: #94a3b8;
      --text-muted: #64748b;
      --border-color: #334155;
      --code-bg: #0f172a;
      --success: #22c55e;
      --shadow-blue: 0 4px 30px rgba(59, 130, 246, 0.15);
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    html {
      scroll-behavior: smooth;
    }

    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
      background: var(--bg-primary);
      color: var(--text-primary);
      line-height: 1.7;
      min-height: 100vh;
    }

    /* Gradient background */
    .bg-gradient {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      height: 600px;
      background: radial-gradient(ellipse 80% 50% at 50% -20%, rgba(59, 130, 246, 0.15), transparent);
      pointer-events: none;
      z-index: -1;
    }

    /* Container */
    .container {
      max-width: 900px;
      margin: 0 auto;
      padding: 0 1.5rem;
    }

    /* Header */
    .header {
      padding: 5rem 0 4rem;
      text-align: center;
    }

    .header-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 50px;
      padding: 0.4rem 1rem;
      font-size: 0.8rem;
      color: var(--text-secondary);
      margin-bottom: 1.5rem;
    }

    .header-badge .dot {
      width: 8px;
      height: 8px;
      background: var(--success);
      border-radius: 50%;
      animation: pulse 2s infinite;
    }

    @keyframes pulse {
      0%, 100% { opacity: 1; }
      50% { opacity: 0.5; }
    }

    .logo {
      font-size: 2.75rem;
      font-weight: 700;
      color: var(--text-primary);
      letter-spacing: -1px;
      margin-bottom: 1rem;
    }

    .logo-icon {
      display: inline-block;
      width: 48px;
      height: 48px;
      background: linear-gradient(135deg, var(--accent-blue), var(--accent-cyan));
      border-radius: 12px;
      margin-right: 0.75rem;
      vertical-align: middle;
      position: relative;
    }

    .logo-icon::before {
      content: "";
      position: absolute;
      top: 55%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 26px;
      height: 18px;
      border: 3px solid white;
      border-radius: 3px;
    }

    .logo-icon::after {
      content: "";
      position: absolute;
      top: 35%;
      left: 50%;
      transform: translate(-50%, -50%);
      width: 18px;
      height: 12px;
      background: white;
      border-radius: 2px;
    }

    .tagline {
      color: var(--text-secondary);
      font-size: 1.15rem;
      font-weight: 400;
      max-width: 550px;
      margin: 0 auto 2rem;
    }

    /* Command box */
    .command-box {
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 1.25rem 1.5rem;
      max-width: 600px;
      margin: 0 auto;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      transition: border-color 0.2s, box-shadow 0.2s;
    }

    .command-box:hover {
      border-color: var(--accent-blue);
      box-shadow: var(--shadow-blue);
    }

    .command-box code {
      font-family: 'Fira Code', monospace;
      font-size: 0.9rem;
      color: var(--accent-cyan);
      flex: 1;
      overflow-x: auto;
    }

    .command-box .prefix {
      color: var(--text-muted);
    }

    .copy-btn {
      background: var(--accent-blue);
      color: white;
      border: none;
      border-radius: 8px;
      padding: 0.6rem 1rem;
      font-size: 0.8rem;
      font-weight: 500;
      cursor: pointer;
      transition: background 0.2s, transform 0.1s;
      white-space: nowrap;
    }

    .copy-btn:hover {
      background: var(--accent-blue-dark);
    }

    .copy-btn:active {
      transform: scale(0.97);
    }

    /* Sections */
    section {
      padding: 4rem 0;
    }

    .section-header {
      text-align: center;
      margin-bottom: 3rem;
    }

    .section-header h2 {
      font-size: 1.75rem;
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 0.75rem;
    }

    .section-header p {
      color: var(--text-secondary);
      font-size: 1rem;
      max-width: 500px;
      margin: 0 auto;
    }

    /* Features grid */
    .features-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1.25rem;
    }

    .feature-card {
      background: var(--bg-card);
      border: 1px solid var(--border-color);
      border-radius: 16px;
      padding: 1.75rem;
      transition: transform 0.2s, border-color 0.2s, box-shadow 0.2s;
    }

    .feature-card:hover {
      transform: translateY(-4px);
      border-color: var(--accent-blue);
      box-shadow: var(--shadow-blue);
    }

    .feature-icon {
      width: 44px;
      height: 44px;
      background: linear-gradient(135deg, rgba(59, 130, 246, 0.2), rgba(34, 211, 238, 0.1));
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.25rem;
      margin-bottom: 1rem;
    }

    .feature-card h3 {
      font-size: 1.05rem;
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 0.5rem;
    }

    .feature-card p {
      color: var(--text-secondary);
      font-size: 0.9rem;
      line-height: 1.6;
    }

    /* Code blocks */
    .code-section {
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 16px;
      overflow: hidden;
    }

    .code-header {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      padding: 0.75rem 1.25rem;
      background: rgba(0,0,0,0.2);
      border-bottom: 1px solid var(--border-color);
    }

    .code-dot {
      width: 12px;
      height: 12px;
      border-radius: 50%;
    }

    .code-dot.red { background: #ef4444; }
    .code-dot.yellow { background: #eab308; }
    .code-dot.green { background: #22c55e; }

    .code-title {
      margin-left: 0.75rem;
      font-size: 0.8rem;
      color: var(--text-muted);
    }

    pre {
      margin: 0;
      padding: 1.5rem;
      overflow-x: auto;
    }

    pre code {
      font-family: 'Fira Code', monospace;
      font-size: 0.85rem;
      line-height: 1.7;
      color: var(--text-primary);
    }

    .code-comment {
      color: var(--text-muted);
    }

    .code-command {
      color: var(--accent-cyan);
    }

    .code-string {
      color: var(--accent-orange);
    }

    /* What's backed up */
    .backup-list {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1rem;
      margin-top: 2rem;
    }

    .backup-item {
      display: flex;
      align-items: center;
      gap: 0.75rem;
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 10px;
      padding: 1rem 1.25rem;
    }

    .backup-item .icon {
      font-size: 1.25rem;
    }

    .backup-item span {
      color: var(--text-secondary);
      font-size: 0.9rem;
    }

    /* Compatibility */
    .compat-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 1rem;
    }

    .compat-card {
      background: var(--bg-secondary);
      border: 1px solid var(--border-color);
      border-radius: 12px;
      padding: 1.5rem;
      text-align: center;
    }

    .compat-card .distro {
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 0.25rem;
    }

    .compat-card .version {
      font-size: 0.8rem;
      color: var(--text-muted);
      margin-bottom: 0.75rem;
    }

    .compat-card .status {
      display: inline-block;
      padding: 0.25rem 0.75rem;
      border-radius: 50px;
      font-size: 0.75rem;
      font-weight: 500;
    }

    .compat-card .status.ok {
      background: rgba(34, 197, 94, 0.15);
      color: var(--success);
    }

    .compat-card .status.planned {
      background: rgba(249, 115, 22, 0.15);
      color: var(--accent-orange);
    }

    /* Footer */
    .footer {
      padding: 3rem 0;
      text-align: center;
      border-top: 1px solid var(--border-color);
      margin-top: 2rem;
    }

    .footer-links {
      display: flex;
      justify-content: center;
      gap: 2rem;
      margin-bottom: 1.5rem;
    }

    .footer-links a {
      color: var(--text-secondary);
      text-decoration: none;
      font-size: 0.9rem;
      transition: color 0.2s;
    }

    .footer-links a:hover {
      color: var(--accent-blue-light);
    }

    .footer-copy {
      color: var(--text-muted);
      font-size: 0.8rem;
    }

    /* Responsive */
    @media (max-width: 768px) {
      .header {
        padding: 3rem 0 2.5rem;
      }

      .logo {
        font-size: 1.75rem;
      }

      .logo-icon {
        width: 36px;
        height: 36px;
        border-radius: 8px;
      }

      .logo-icon::after {
        font-size: 1.1rem;
      }

      .tagline {
        font-size: 1rem;
      }

      .command-box {
        flex-direction: column;
        text-align: center;
      }

      .command-box code {
        font-size: 0.8rem;
      }

      .features-grid {
        grid-template-columns: 1fr;
      }

      .backup-list {
        grid-template-columns: 1fr;
      }

      .compat-grid {
        grid-template-columns: repeat(2, 1fr);
      }

      section {
        padding: 2.5rem 0;
      }
    }

    /* Animations */
    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(20px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .header, section {
      animation: fadeIn 0.6s ease-out backwards;
    }

    section:nth-of-type(1) { animation-delay: 0.1s; }
    section:nth-of-type(2) { animation-delay: 0.2s; }
    section:nth-of-type(3) { animation-delay: 0.3s; }
    section:nth-of-type(4) { animation-delay: 0.4s; }
  </style>
</head>

<body>
  <div class="bg-gradient"></div>

  <div class="container">
    <!-- Header -->
    <header class="header">
      <div class="header-badge">
        <span class="dot"></span>
        <span>v2.0.0 — Open Source</span>
      </div>

      <h1 class="logo">
        <span class="logo-icon"></span>
        qBittorrent Backup
      </h1>

      <p class="tagline">
        Backup and restore your qBittorrent configuration on Linux with a single command
      </p>

      <div class="command-box">
        <code><span class="prefix">$</span> curl -sL qbt.cantalupo.com.br | bash</code>
        <button class="copy-btn" onclick="copyCommand()">Copy</button>
      </div>
    </header>

    <!-- Features -->
    <section>
      <div class="section-header">
        <h2>Why use this tool?</h2>
        <p>Simple, reliable, and designed for the Linux community</p>
      </div>

      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">📦</div>
          <h3>Complete Backup</h3>
          <p>Saves all configuration files, torrent metadata, statistics, and logs in a single ZIP file.</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">⚡</div>
          <h3>One Command</h3>
          <p>No installation required. Just run the command and follow the interactive menu.</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">🔄</div>
          <h3>Easy Restore</h3>
          <p>Restore everything with a single click. All settings and torrent list are preserved.</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">📦</div>
          <h3>Flatpak Support</h3>
          <p>Works with both standard and Flatpak installations automatically.</p>
        </div>
      </div>
    </section>

    <!-- What's backed up -->
    <section>
      <div class="section-header">
        <h2>What's included in the backup?</h2>
        <p>Everything you need to restore your qBittorrent setup</p>
      </div>

      <div class="backup-list">
        <div class="backup-item">
          <span class="icon">⚙️</span>
          <span>Settings & Preferences</span>
        </div>
        <div class="backup-item">
          <span class="icon">📊</span>
          <span>Statistics & History</span>
        </div>
        <div class="backup-item">
          <span class="icon">📁</span>
          <span>Torrent List</span>
        </div>
        <div class="backup-item">
          <span class="icon">🏷️</span>
          <span>Categories & Tags</span>
        </div>
        <div class="backup-item">
          <span class="icon">🔗</span>
          <span>RSS Feeds</span>
        </div>
        <div class="backup-item">
          <span class="icon">📝</span>
          <span>Application Logs</span>
        </div>
      </div>
    </section>

    <!-- Usage -->
    <section>
      <div class="section-header">
        <h2>How to use</h2>
        <p>Get started in seconds</p>
      </div>

      <div class="code-section">
        <div class="code-header">
          <span class="code-dot red"></span>
          <span class="code-dot yellow"></span>
          <span class="code-dot green"></span>
          <span class="code-title">terminal</span>
        </div>
        <pre><code><span class="code-comment"># Run directly from the web</span>
<span class="code-command">curl -sL qbt.cantalupo.com.br | bash</span>

<span class="code-comment"># Or with wget</span>
<span class="code-command">wget -qO- qbt.cantalupo.com.br | bash</span>

<span class="code-comment"># Clone and run locally</span>
<span class="code-command">git clone</span> <span class="code-string">https://github.com/cantalupo555/qbittorrent-backup-linux.git</span>
<span class="code-command">cd</span> qbittorrent-backup-linux
<span class="code-command">./src/main.sh</span></code></pre>
      </div>
    </section>

    <!-- Compatibility -->
    <section>
      <div class="section-header">
        <h2>Compatibility</h2>
        <p>Tested on popular Linux distributions</p>
      </div>

      <div class="compat-grid">
        <div class="compat-card">
          <div class="distro">Ubuntu</div>
          <div class="version">22.04+</div>
          <span class="status ok">Supported</span>
        </div>
        <div class="compat-card">
          <div class="distro">Debian</div>
          <div class="version">11+</div>
          <span class="status ok">Supported</span>
        </div>
        <div class="compat-card">
          <div class="distro">Fedora</div>
          <div class="version">38+</div>
          <span class="status planned">Planned</span>
        </div>
        <div class="compat-card">
          <div class="distro">Arch</div>
          <div class="version">Latest</div>
          <span class="status planned">Planned</span>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="footer-links">
        <a href="https://github.com/cantalupo555/qbittorrent-backup-linux">GitHub</a>
        <a href="https://github.com/cantalupo555/qbittorrent-backup-linux/blob/master/LICENSE">MIT License</a>
        <a href="https://github.com/cantalupo555/qbittorrent-backup-linux/issues">Report Issue</a>
        <a href="https://github.com/cantalupo555">Author</a>
      </div>
      <p class="footer-copy">
        Made with care for the Linux community
      </p>
    </footer>
  </div>

  <script>
    function copyCommand() {
      const cmd = 'curl -sL qbt.cantalupo.com.br | bash';
      navigator.clipboard.writeText(cmd).then(() => {
        const btn = document.querySelector('.copy-btn');
        btn.textContent = 'Copied!';
        setTimeout(() => btn.textContent = 'Copy', 2000);
      });
    }
  </script>
</body>

</html>
EOF

echo "index.html generated successfully"
