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

Lista em `extensoes-necessarias.txt`; o `restaurar.ps1` instala sozinho.

| Extensão | Para quê |
|---|---|
| `be5invis.vscode-custom-css` | Custom CSS and JS Loader: carrega o `cursor-like.css` |
| `anthropic.claude-code` | Claude Code (o chat) |
| `cedricverlinden.cursor-dark` | Tema de cores `cursor-less-dark` |
| `miguelsolorio.symbols` | Tema de ícones discreto "Symbols" |

`extensoes-todas.txt` tem todas as extensões instaladas hoje (SQL Server, Python, SQLite etc.), para quem quiser o mesmo ambiente completo.

Fonte: JetBrains Mono. O `restaurar.ps1` baixa e instala só para o usuário atual (sem administrador). Se não conseguir (sem internet, proxy), avisa; sem ela, o editor usa a Cascadia Code do Windows.

## Restaurar

```powershell
powershell -ExecutionPolicy Bypass -File .\restaurar.ps1          # só as extensões necessárias
powershell -ExecutionPolicy Bypass -File .\restaurar.ps1 -Todas   # todas as extensões
```

O script, nesta ordem:

1. Instala as extensões. Se o comando `code` não estiver no PATH, avisa como resolver e segue.
2. Instala a fonte JetBrains Mono, se ainda não estiver instalada.
3. Copia `keybindings.json` e os arquivos de `vscode/` para `%USERPROFILE%\.vscode\`.
4. Copia o `settings.json` do VS Code trocando o caminho do CSS (`file:///C:/Users/<usuário>/.vscode/...`) pela pasta do usuário atual.
5. No `%USERPROFILE%\.claude\settings.json`, só acrescenta `DISABLE_TELEMETRY` e `DISABLE_ERROR_REPORTING` no `env`, mantendo o resto. O `claude/settings.json` deste repositório não é copiado inteiro: ele tem hooks do Orca e plugins desta máquina, que falhariam num computador sem eles. Fica aqui só para consulta.
6. Aplica o CSS do chat do Claude Code.

Antes de sobrescrever qualquer arquivo, guarda uma cópia `.bak`. Depois, no VS Code: `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.

## Depois de atualizar

- **VS Code:** `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.
- **Extensão do Claude Code:** rode `%USERPROFILE%\.vscode\aplicar-chat-css.ps1` e recarregue a janela.

## Não fica aqui

Os ícones escondidos na barra de atividades e a posição dos painéis (por exemplo, o Claude Code na barra da direita) ficam na memória interna do VS Code, não em arquivo de configuração. Para levar isso também:

- **Settings Sync:** engrenagem → **Backup and Sync Settings…**, com conta Microsoft ou GitHub; ou
- **Refazer à mão:** botão direito na barra de ícones do topo da lateral → desmarcar os que não usa; arrastar o ícone do Claude Code para a barra da direita.
