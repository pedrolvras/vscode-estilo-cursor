# VS Code com visual do Cursor

Configurações para deixar o VS Code com layout, visual e atalhos parecidos com os do Cursor, mais o chat do Claude Code no mesmo estilo e a telemetria desligada.

## Instalar com o Claude Code

Só no Windows, com o VS Code normal (não o Insiders) e o Claude Code instalados. Abra o Claude Code em qualquer pasta e cole o prompt abaixo:

```text
Instale no meu VS Code as configurações do repositório https://github.com/pedrolvras/vscode-estilo-cursor.

1. Clone o repositório em %USERPROFILE%\vscode-estilo-cursor e leia o README.md e o restaurar.ps1 inteiros antes de mudar qualquer coisa.
2. Não rode o restaurar.ps1 do jeito que está: ele substitui meu settings.json e meu keybindings.json inteiros. Faça os passos dele um a um, assim:
   a. Extensões: instale as de extensoes-necessarias.txt com `code --install-extension`. Se o comando `code` não existir, me diga como colocá-lo no PATH e siga com o resto.
   b. Fonte: instale a JetBrains Mono como no bloco "1b" do restaurar.ps1 (só para o meu usuário, sem administrador). Se o download falhar, me avise e siga.
   c. Copie cursor-like.css, fechar-menu.js, rodape-blame.js, cursor-chat.css e aplicar-chat-css.ps1 de vscode\ para %USERPROFILE%\.vscode\.
   d. settings.json do VS Code (%APPDATA%\Code\User\settings.json): guarde uma cópia .bak e JUNTE as configurações de vscode\settings.json com as minhas, sem apagar as que já tenho. Em conflito, me mostre a lista e pergunte qual fica. No `vscode_custom_css.imports`, troque o caminho para a minha pasta de usuário (file:///C:/Users/<meu usuário>/.vscode/..., nas três linhas).
   e. keybindings.json (%APPDATA%\Code\User\keybindings.json): guarde uma cópia .bak e ACRESCENTE os atalhos de vscode\keybindings.json aos meus, sem apagar os que já tenho. Avise se algum atalho meu usar Ctrl+L ou Ctrl+I.
   f. Claude Code (%USERPROFILE%\.claude\settings.json): guarde uma cópia .bak e só acrescente "DISABLE_TELEMETRY": "1" e "DISABLE_ERROR_REPORTING": "1" no "env", mantendo o resto. NÃO copie o claude\settings.json do repositório: ele é de outra máquina.
   g. Rode %USERPROFILE%\.vscode\aplicar-chat-css.ps1 para aplicar o visual do chat.
3. Confira que os JSON continuam válidos e me diga o que foi feito e o que ficou de fora.
4. No fim, me liste o que eu preciso fazer à mão: Ctrl+Shift+P > "Enable Custom CSS and JS" e reiniciar o VS Code; esconder os ícones que não uso (botão direito na barra de ícones do topo da lateral); arrastar o ícone do Claude Code para a barra da direita.
```

O `restaurar.ps1` direto (seção "Restaurar") serve para restaurar na **mesma** máquina ou para quem não tem configurações próprias a preservar.

## Deixar idêntico à máquina de origem (substitui tudo)

Para outra máquina minha, onde quero o VS Code igual ao da origem e não preciso preservar nada, cole no Claude Code:

```text
Deixe o VS Code deste PC idêntico ao do repositório https://github.com/pedrolvras/vscode-estilo-cursor (clone em %USERPROFILE%\vscode-estilo-cursor se ainda não estiver lá).

1. Na pasta do repositório, rode `git pull` e leia o README.md e o restaurar.ps1 inteiros antes de mudar qualquer coisa.
2. Rode `powershell -ExecutionPolicy Bypass -File .\restaurar.ps1 -Todas`. Ele substitui settings.json e keybindings.json inteiros (guarda .bak-<data-hora> antes), instala todas as extensões, as duas locais e o ícone cinza, e no fim lista as extensões que faltaram. Se ele parar dizendo que o repositório está atrás do GitHub, rode `git pull` e de novo. Se o comando `code` não existir, me diga como resolver.
3. Confira que o vscode_custom_css.imports do %APPDATA%\Code\User\settings.json aponta para a MINHA pasta de usuário e que os arquivos existem em %USERPROFILE%\.vscode\, e que os JSON são válidos.
4. Me diga o que foi feito, o que falhou, e o que preciso fazer à mão.
```

## Manter as máquinas iguais

O que deixa uma máquina diferente da outra é aplicar uma cópia velha do repositório. Para evitar:

- **Mudou algo na máquina de origem** (settings, CSS, extensão nova): copie o arquivo para cá, atualize `extensoes-todas.txt` se for extensão (`code --list-extensions`), faça commit **e push**.
- **Na outra máquina:** `git pull` e `restaurar.ps1 -Todas`. O script confere sozinho se o repositório está atrás do GitHub e para antes de aplicar uma versão velha (`-SemAtualizar` pula essa conferência).
- **Configuração que só existe numa máquina** some quando a outra aplica o `settings.json` inteiro. Se é para valer nas duas, ponha no `vscode/settings.json` daqui.

## O que tem aqui

| Arquivo | Vai para | Para quê |
|---|---|---|
| `vscode/settings.json` | `%APPDATA%\Code\User\` | Layout, tema, fonte, cores dos menus, telemetria desligada, atualização manual, salvar sozinho |
| `vscode/keybindings.json` | `%APPDATA%\Code\User\` | `Ctrl+L` abre o chat do Claude; `Ctrl+I` manda a seleção para o chat |
| `vscode/cursor-like.css` | `%USERPROFILE%\.vscode\` | Visual da janela (linhas finas, abas, menus, tela de configurações, ícones), carregado pelo Custom CSS and JS Loader |
| `vscode/fechar-menu.js` | `%USERPROFILE%\.vscode\` | Menu do topo (compacto) fecha sozinho quando o mouse sai |
| `vscode/rodape-blame.js` | `%USERPROFILE%\.vscode\` | Leva o autor da linha (git blame) para o lado esquerdo do rodapé |
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
| `chadalen.vscode-jetbrains-icon-theme` | Tema de ícones dos arquivos no estilo JetBrains (2023 dark) |

`extensoes-todas.txt` tem, além dessas, todas as outras que uso: contador de uso do Claude, ícones Symbols, PDF, SQL Server (mssql), SQLTools e SQLite, Python. As duas locais não estão no marketplace e ficam fora da lista: `local.copiar-arroba` (`opcional/copiar-arroba/`) e `local.scriptcase-php` (`opcional/php-sem-tag/`). O `restaurar.ps1 -Todas` instala as duas; sem `-Todas`, instale pelo `README.md` de cada uma.

Fonte: o editor e o terminal usam a Cascadia Code / Cascadia Mono, que já vêm no Windows. O `restaurar.ps1` ainda instala a JetBrains Mono (só para o usuário atual, sem administrador) para quem quiser trocar no `settings.json`.

## Opcional

Os três entram no `restaurar.ps1 -Todas`; sem `-Todas`, rode cada um à parte.

- **`icone/icone-cinza.ps1`:** troca o ícone azul do VS Code por um cinza (gerado a partir do ícone instalado) nos atalhos do menu Iniciar, da área de trabalho e da barra de tarefas (o da barra de título fica cinza pelo `cursor-like.css`); `-Remover` volta ao azul. Depois de atualizar o VS Code, rodar de novo se o ícone voltar ao azul.
- **`opcional/copiar-arroba/`:** `Ctrl+C` num arquivo do explorador também copia `@caminho` para colar no chat do Claude Code; liga e desliga pelo botão `@` no rodapé. Instalar como no `README.md` dela.
- **`opcional/php-sem-tag/`:** extensão local que colore como PHP arquivos sem `<?php` (eventos do Scriptcase, por exemplo). Instalar como no `README.md` dela; a associação dos arquivos é sempre por projeto.

## Restaurar

```powershell
powershell -ExecutionPolicy Bypass -File .\restaurar.ps1          # só as extensões necessárias
powershell -ExecutionPolicy Bypass -File .\restaurar.ps1 -Todas   # idêntico à origem: todas as extensões, as locais e o ícone
```

O script, nesta ordem:

0. Confere se o repositório está em dia com o GitHub. Se estiver atrás, para e pede `git pull` (`-SemAtualizar` pula). Se tiver commits locais não enviados, avisa para fazer push.
1. Instala as extensões (com `-Todas`, também as duas locais de `opcional/`). Se o comando `code` não estiver no PATH, usa o da instalação padrão do VS Code; se nem esse existir, avisa como resolver e segue.
2. Instala a fonte JetBrains Mono, se ainda não estiver instalada.
3. Copia `keybindings.json` e os arquivos de `vscode/` para `%USERPROFILE%\.vscode\`.
4. Copia o `settings.json` do VS Code trocando o caminho do CSS (`file:///C:/Users/<usuário>/.vscode/...`) pela pasta do usuário atual.
5. No `%USERPROFILE%\.claude\settings.json`, só acrescenta `DISABLE_TELEMETRY` e `DISABLE_ERROR_REPORTING` no `env`, mantendo o resto. O `claude/settings.json` deste repositório não é copiado inteiro: ele tem hooks do Orca e plugins desta máquina, que falhariam num computador sem eles. Fica aqui só para consulta.
6. Aplica o CSS do chat do Claude Code.
7. Com `-Todas`, troca o ícone dos atalhos pelo cinza.
8. Confere com `code --list-extensions` e lista as extensões que não instalaram.

Antes de sobrescrever qualquer arquivo, guarda uma cópia `.bak-<data-hora>` (as anteriores ficam). Depois, no VS Code: `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.

## Depois de atualizar

- **VS Code:** `Ctrl+Shift+P` → **Enable Custom CSS and JS** e reinicie.
- **Extensão do Claude Code:** rode `%USERPROFILE%\.vscode\aplicar-chat-css.ps1` e recarregue a janela.

## Não fica aqui

Os ícones escondidos na barra de atividades e a posição dos painéis (por exemplo, o Claude Code na barra da direita) ficam na memória interna do VS Code, não em arquivo de configuração. Para levar isso também:

- **Settings Sync:** engrenagem → **Backup and Sync Settings…**, com conta Microsoft ou GitHub; ou
- **Refazer à mão:** botão direito na barra de ícones do topo da lateral → desmarcar os que não usa; arrastar o ícone do Claude Code para a barra da direita.
