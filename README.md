# VS Code com visual do Cursor

Configurações para deixar o VS Code com layout, visual e atalhos parecidos com os do Cursor, mais o chat do Claude Code no mesmo estilo e a telemetria desligada.

## O que tem aqui

| Arquivo | Vai para | Para quê |
|---|---|---|
| `vscode/settings.json` | `%APPDATA%\Code\User\` | Layout, tema, fonte, cores dos menus, telemetria desligada, atualização manual, salvar sozinho |
| `vscode/keybindings.json` | `%APPDATA%\Code\User\` | `Ctrl+L` abre o chat do Claude; `Ctrl+I` manda a seleção para o chat |
| `vscode/cursor-like.css` | `%USERPROFILE%\.vscode\` | Visual da janela (linhas finas, abas, menus, tela de configurações, ícones), carregado pelo Custom CSS and JS Loader |
| `vscode/cursor-chat.css` | `%USERPROFILE%\.vscode\` | Visual do chat do Claude Code (cartão da mensagem, caixa de digitar, botões) |
| `vscode/aplicar-chat-css.ps1` | `%USERPROFILE%\.vscode\` | Aplica o `cursor-chat.css` na extensão do Claude Code (`-Remover` desfaz) |
| `claude/settings.json` | `%USERPROFILE%\.claude\` | Configuração do Claude Code, com telemetria e relatório de erros desligados |

## Extensões necessárias

- `be5invis.vscode-custom-css` (Custom CSS and JS Loader)
- `anthropic.claude-code` (Claude Code)
- Tema `cursor-less-dark`
- `miguelsolorio.symbols` (ícones)

Fonte opcional: JetBrains Mono (sem ela, usa a Cascadia Code do Windows).

## Restaurar

```powershell
powershell -ExecutionPolicy Bypass -File .\restaurar.ps1
```

O script guarda uma cópia `.bak` de cada arquivo que já existe antes de sobrescrever. Depois, no VS Code: `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.

## Depois de atualizar

- **VS Code:** `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.
- **Extensão do Claude Code:** rode `%USERPROFILE%\.vscode\aplicar-chat-css.ps1` e recarregue a janela.

## Não fica aqui

Os ícones escondidos na barra de atividades e a posição dos painéis ficam na memória interna do VS Code. Para guardar isso também, use o Settings Sync (engrenagem → Backup and Sync Settings…).
