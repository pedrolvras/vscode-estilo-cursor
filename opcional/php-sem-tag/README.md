# PHP sem `<?php` (opcional)

Só para quem edita PHP que não começa com `<?php`, como eventos do Scriptcase copiados para arquivos
locais. Sem a tag, o VS Code mostra o arquivo inteiro como texto, sem cor.

A extensão cria a linguagem "PHP Scriptcase" (`php-scriptcase`), que usa a gramática do PHP do próprio
VS Code desde a primeira linha. Ela não muda nada sozinha: só os arquivos associados a ela ficam assim.

## Instalar

```powershell
powershell -ExecutionPolicy Bypass -File .\opcional\php-sem-tag\instalar.ps1
```

Depois, no `.vscode/settings.json` **do projeto** (não no do usuário), associe os arquivos:

```json
"files.associations": { "**/pasta dos eventos/*.php": "php-scriptcase" }
```

e recarregue a janela (`Ctrl+Shift+P` → "Reload Window").

Efeito colateral: extensões só de PHP (Intelephense etc.) não rodam nos arquivos associados.
